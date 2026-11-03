const { createHash, randomBytes } = require("node:crypto");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { HttpsError, onCall } = require("firebase-functions/v2/https");

const region = "us-central1";
const inviteLifetimeMs = 7 * 24 * 60 * 60 * 1000;
const codeAlphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function requireUser(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  return request.auth;
}

function requireText(value, label, maxLength) {
  if (typeof value !== "string" || !value.trim() || value.trim().length > maxLength) {
    throw new HttpsError("invalid-argument", `${label} 값을 확인해 주세요.`);
  }
  return value.trim();
}

function codeHash(code) {
  return createHash("sha256").update(code).digest("hex");
}

function newInviteCode() {
  const bytes = randomBytes(10);
  return Array.from(bytes, (byte) => codeAlphabet[byte % codeAlphabet.length]).join("");
}

function displayNameFor(user) {
  return user.token.name || user.token.email || "가족 구성원";
}

function memberRef(db, groupId, uid) {
  return db.doc(`groups/${groupId}/members/${uid}`);
}

async function requireAdmin(transaction, db, groupId, uid) {
  const snapshot = await transaction.get(memberRef(db, groupId, uid));
  if (!snapshot.exists || snapshot.get("role") !== "admin") {
    throw new HttpsError("permission-denied", "가족 관리자만 할 수 있습니다.");
  }
}

exports.createFamily = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const name = requireText(request.data?.name, "가족 이름", 60);
  const db = getFirestore();
  const groupRef = db.collection("groups").doc();

  await db.runTransaction(async (transaction) => {
    transaction.create(groupRef, {
      name,
      createdAt: FieldValue.serverTimestamp(),
      createdBy: user.uid,
    });
    transaction.create(memberRef(db, groupRef.id, user.uid), {
      uid: user.uid,
      displayName: displayNameFor(user),
      role: "admin",
      joinedAt: FieldValue.serverTimestamp(),
    });
  });
  return { groupId: groupRef.id, name };
});

exports.getFamilyOverview = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const groupId = requireText(request.data?.groupId, "가족", 128);
  const db = getFirestore();
  const groupRef = db.doc(`groups/${groupId}`);
  const memberCollection = groupRef.collection("members");
  const joinRequestCollection = groupRef.collection("joinRequests");
  const [group, myMembership] = await Promise.all([
    groupRef.get(),
    memberRef(db, groupId, user.uid).get(),
  ]);
  if (!group.exists || !myMembership.exists) {
    throw new HttpsError("permission-denied", "승인된 가족 구성원만 볼 수 있습니다.");
  }

  const isAdmin = myMembership.get("role") === "admin";
  const [members, requests] = await Promise.all([
    memberCollection.get(),
    isAdmin ? joinRequestCollection.where("status", "==", "pending").get() : Promise.resolve(null),
  ]);
  return {
    groupId,
    groupName: group.get("name"),
    members: members.docs.map((doc) => ({
      id: doc.id,
      displayName: doc.get("displayName") || "가족 구성원",
      roleLabel: doc.get("role") === "admin" ? "관리자" : "구성원",
    })),
    joinRequests: (requests?.docs || []).map((doc) => ({
      id: doc.id,
      displayName: doc.get("displayName") || "가족 구성원",
    })),
    canCreateInviteCode: isAdmin,
    canApproveJoinRequests: isAdmin,
    removableMemberIds: isAdmin
      ? members.docs.filter((doc) => doc.get("role") !== "admin").map((doc) => doc.id)
      : [],
  };
});

exports.listMyFamilies = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const memberships = await getFirestore()
    .collectionGroup("members")
    .where("uid", "==", user.uid)
    .get();
  const groups = await Promise.all(memberships.docs.map(async (membership) => {
    const groupRef = membership.ref.parent.parent;
    const group = await groupRef.get();
    if (!group.exists) return null;
    return { groupId: group.id, groupName: group.get("name") || "가족" };
  }));
  return { groups: groups.filter(Boolean) };
});

exports.getFamilyJoinStatus = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const groupId = requireText(request.data?.groupId, "가족", 128);
  const db = getFirestore();
  const [member, joinRequest] = await Promise.all([
    memberRef(db, groupId, user.uid).get(),
    db.doc(`groups/${groupId}/joinRequests/${user.uid}`).get(),
  ]);
  if (member.exists) return { status: "approved" };
  if (joinRequest.exists && joinRequest.get("status") === "pending") return { status: "pending" };
  return { status: "none" };
});

exports.createFamilyInviteCode = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const groupId = requireText(request.data?.groupId, "가족", 128);
  const db = getFirestore();
  const groupRef = db.doc(`groups/${groupId}`);
  const code = newInviteCode();
  const hash = codeHash(code);
  const expiresAt = Timestamp.fromMillis(Date.now() + inviteLifetimeMs);

  await db.runTransaction(async (transaction) => {
    await requireAdmin(transaction, db, groupId, user.uid);
    const group = await transaction.get(groupRef);
    if (!group.exists) throw new HttpsError("not-found", "가족을 찾을 수 없습니다.");
    const previousHash = group.get("activeInviteCodeHash");
    if (previousHash) transaction.delete(db.doc(`familyInviteCodes/${previousHash}`));
    transaction.create(db.doc(`familyInviteCodes/${hash}`), {
      groupId,
      expiresAt,
      createdAt: FieldValue.serverTimestamp(),
      createdBy: user.uid,
    });
    transaction.update(groupRef, { activeInviteCodeHash: hash });
  });
  return { code, expiresAt: expiresAt.toDate().toISOString() };
});

exports.requestFamilyJoin = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const code = requireText(request.data?.code, "초대 코드", 12).toUpperCase();
  if (!/^[A-Z0-9]{6,12}$/.test(code)) {
    throw new HttpsError("invalid-argument", "초대 코드를 확인해 주세요.");
  }
  const db = getFirestore();
  const codeRef = db.doc(`familyInviteCodes/${codeHash(code)}`);
  const inviteSnapshot = await codeRef.get();
  if (!inviteSnapshot.exists) {
    throw new HttpsError("not-found", "유효한 초대 코드를 찾을 수 없습니다.");
  }
  const groupId = inviteSnapshot.get("groupId");
  const groupRef = db.doc(`groups/${groupId}`);
  const ownMemberRef = memberRef(db, groupId, user.uid);
  const ownRequestRef = groupRef.collection("joinRequests").doc(user.uid);
  await db.runTransaction(async (transaction) => {
    const [invite, group, existingMember, existingRequest] = await Promise.all([
      transaction.get(codeRef),
      transaction.get(groupRef),
      transaction.get(ownMemberRef),
      transaction.get(ownRequestRef),
    ]);
    if (!invite.exists || invite.get("expiresAt").toMillis() <= Date.now()
      || !group.exists || group.get("activeInviteCodeHash") !== codeHash(code)) {
      throw new HttpsError("not-found", "유효한 초대 코드를 찾을 수 없습니다.");
    }
    if (existingMember.exists) throw new HttpsError("already-exists", "이미 가족 구성원입니다.");
    if (existingRequest.exists && existingRequest.get("status") === "pending") return;
    transaction.set(ownRequestRef, {
      uid: user.uid,
      displayName: displayNameFor(user),
      status: "pending",
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { groupId, status: "pending" };
});

exports.approveFamilyJoinRequest = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const groupId = requireText(request.data?.groupId, "가족", 128);
  const requestId = requireText(request.data?.requestId, "가입 요청", 128);
  const db = getFirestore();
  const groupRef = db.doc(`groups/${groupId}`);
  const joinRef = groupRef.collection("joinRequests").doc(requestId);
  const targetMemberRef = memberRef(db, groupId, requestId);

  await db.runTransaction(async (transaction) => {
    await requireAdmin(transaction, db, groupId, user.uid);
    const joinRequest = await transaction.get(joinRef);
    if (!joinRequest.exists || joinRequest.get("status") !== "pending") {
      throw new HttpsError("not-found", "대기 중인 가입 요청을 찾을 수 없습니다.");
    }
    transaction.create(targetMemberRef, {
      uid: requestId,
      displayName: joinRequest.get("displayName") || "가족 구성원",
      role: "member",
      joinedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(joinRef, { status: "approved", reviewedAt: FieldValue.serverTimestamp(), reviewedBy: user.uid });
  });
  return { approved: true };
});

exports.removeFamilyMember = onCall({ region }, async (request) => {
  const user = requireUser(request);
  const groupId = requireText(request.data?.groupId, "가족", 128);
  const memberId = requireText(request.data?.memberId, "구성원", 128);
  const db = getFirestore();
  const groupRef = db.doc(`groups/${groupId}`);
  const targetRef = memberRef(db, groupId, memberId);

  await db.runTransaction(async (transaction) => {
    await requireAdmin(transaction, db, groupId, user.uid);
    const target = await transaction.get(targetRef);
    if (!target.exists) throw new HttpsError("not-found", "구성원을 찾을 수 없습니다.");
    if (target.get("role") === "admin") {
      throw new HttpsError("failed-precondition", "관리자는 이 기능으로 제거할 수 없습니다.");
    }
    transaction.delete(targetRef);
    transaction.set(groupRef.collection("auditEvents").doc(), {
      type: "member_removed",
      actorUid: user.uid,
      subjectUid: memberId,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { removed: true };
});
