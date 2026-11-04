const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { defineSecret } = require("firebase-functions/params");
const { onRequest } = require("firebase-functions/v2/https");

initializeApp();

const metaModelApi = defineSecret("META_MODEL_API");

exports.verifyMetaModelApi = onRequest(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    maxInstances: 2,
    secrets: [metaModelApi],
  },
  async (req, res) => {
    if (req.method !== "GET") {
      res.set("Allow", "GET").status(405).json({ error: "method_not_allowed" });
      return;
    }

    const authorization = req.get("Authorization") || "";
    const match = /^Bearer (.+)$/.exec(authorization);
    if (!match) {
      res.status(401).json({ error: "unauthenticated" });
      return;
    }

    try {
      await getAuth().verifyIdToken(match[1]);
    } catch (_) {
      res.status(401).json({ error: "unauthenticated" });
      return;
    }

    const apiKey = metaModelApi.value().trim();
    if (!apiKey) {
      res.status(503).json({ error: "meta_model_api_not_configured" });
      return;
    }

    try {
      const response = await fetch("https://api.meta.ai/v1/models", {
        headers: { Authorization: `Bearer ${apiKey}` },
        signal: AbortSignal.timeout(15000),
      });
      if (!response.ok) {
        res.status(502).json({ error: "meta_model_api_unavailable" });
        return;
      }

      const payload = await response.json();
      const models = Array.isArray(payload.data)
        ? payload.data
            .map((model) => model.id)
            .filter((id) => typeof id === "string")
        : [];
      res.status(200).json({ available: true, models });
    } catch (_) {
      res.status(502).json({ error: "meta_model_api_unavailable" });
    }
  },
);

Object.assign(exports, require("./family"));
Object.assign(exports, require("./meta_analysis"));

Object.assign(exports, require("./water_levels"));

Object.assign(exports, require("./health_chat"));
