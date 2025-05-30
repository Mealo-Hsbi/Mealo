// 1) Vor dem Laden anderer Module mocken
const mockVerifyIdToken = jest.fn();
jest.mock("../app/firebase", () => ({
  auth: () => ({
    verifyIdToken: mockVerifyIdToken,
  }),
}));

jest.mock("../app/generated/prisma", () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => ({
      users: {
        findUnique: jest.fn().mockResolvedValue({
          firebase_uid: "u1",
          email: "alice@example.com",
        }),
        upsert: jest.fn().mockResolvedValue({
          firebase_uid: "abc123",
          email: "foo@bar.com",
          name: "Test User",
          avatar_url: "profile-pictures/profile_placeholder.png"
        }),
        create: jest.fn().mockResolvedValue({}),
        delete: jest.fn().mockResolvedValue({}),
      },
      $disconnect: jest.fn(), // ✅ wichtig für afterAll
    })),
  };
});

const request = require("supertest");
const express = require("express");

const { PrismaClient } = require("../app/generated/prisma");
const prisma = new PrismaClient();

beforeAll(async () => {
  await prisma.users.create({
    data: {
      firebase_uid: "u1",
      email: "alice@example.com",
      name: "Alice Test",
      avatar_url: "profile-pictures/profile_placeholder.png",
    },
  });
});

describe("User-Routes", () => {
  let app;

  beforeEach(() => {
    // 💡 Jeder Test erhält eine frische Instanz
    app = express();
    app.use(express.json());

    // 🔁 userRoutes erst jetzt importieren, damit der Mock greift
    const userRoutes = require("../app/routes/user.routes");
    app.use("/api/users", userRoutes);
  });

  describe("POST /api/users/register", () => {
    it("returns 201 (stub)", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "foo@bar.com"
      });

      const res = await request(app)
        .post("/api/users/register")
        .set("Authorization", "Bearer dummy.token")
        .send({ name: "Test User" });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty("firebase_uid", "abc123");
    });
  });

  describe("POST /api/users/login", () => {
    it("returns 200 (stub)", async () => {
      const res = await request(app)
        .post("/api/users/login")
        .send({ email: "foo@bar.com", password: "secret" });

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual({ token: "fake-jwt-token" });
    });
  });

  describe("GET /api/users/me", () => {
    it("401 ohne Header", async () => {
      const res = await request(app).get("/api/users/me");
      expect(res.statusCode).toBe(401);
      expect(res.body).toHaveProperty("message", "Kein Token");
    });

    it("401 bei falschem Header-Format", async () => {
      const res = await request(app)
        .get("/api/users/me")
        .set("Authorization", "Invalid token");
      expect(res.statusCode).toBe(401);
    });

    it("200 mit gültigem Token", async () => {
      const fakeDecoded = { uid: "u1", email: "alice@example.com" };
      mockVerifyIdToken.mockResolvedValueOnce(fakeDecoded);

      const res = await request(app)
        .get("/api/users/me")
        .set("Authorization", "Bearer valid.jwt.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty("firebase_uid", "u1");
    });

    it("401 wenn verifyIdToken fehlschlägt", async () => {
      mockVerifyIdToken.mockRejectedValueOnce(new Error("invalid"));
      const res = await request(app)
        .get("/api/users/me")
        .set("Authorization", "Bearer invalid.token");

      expect(res.statusCode).toBe(401);
      expect(res.body).toHaveProperty("message", "Ungültiges Token");
    });
  });

  afterAll(async () => {
  await prisma.users.delete({ where: { firebase_uid: "u1" } });
  await prisma.$disconnect();
});
});
