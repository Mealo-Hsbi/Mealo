// backend/tests/user.routes.test.js

const mockVerifyIdToken = jest.fn();

jest.mock("../app/firebase", () => ({
  auth: () => ({
    verifyIdToken: mockVerifyIdToken,
  }),
}));

const mockFindUnique = jest.fn();
const mockCreate = jest.fn();
const mockUpdate = jest.fn();
const mockDelete = jest.fn();

jest.mock("../app/generated/prisma", () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => ({
      users: {
        findUnique: mockFindUnique,
        create: mockCreate,
        update: mockUpdate,
        delete: mockDelete,
      },
      $disconnect: jest.fn(),
    })),
  };
});

const request = require("supertest");
const express = require("express");
const { PrismaClient } = require("../app/generated/prisma");
const prisma = new PrismaClient();

describe("User-Routes", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());

    const userRoutes = require("../app/routes/user.routes");
    app.use("/api/users", userRoutes);
  });

  describe("POST /api/users/register", () => {
    it("creates a new user when not existing", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "foo@bar.com"
      });

      mockFindUnique.mockResolvedValueOnce(null); // Nutzer existiert nicht
      mockCreate.mockResolvedValueOnce({
        firebase_uid: "abc123",
        email: "foo@bar.com",
        name: "Test User",
        avatar_url: "profile-pictures/profile_placeholder.png"
      });

      const res = await request(app)
        .post("/api/users/register")
        .set("Authorization", "Bearer dummy.token")
        .send({ name: "Test User" });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty("firebase_uid", "abc123");
    });

    it("updates existing user without changing avatar", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "foo@bar.com"
      });

      mockFindUnique.mockResolvedValueOnce({
        firebase_uid: "abc123",
        email: "foo@bar.com",
        name: "Old Name",
        avatar_url: "unchanged.png"
      });

      mockUpdate.mockResolvedValueOnce({
        firebase_uid: "abc123",
        email: "foo@bar.com",
        name: "Test User",
        avatar_url: "unchanged.png"
      });

      const res = await request(app)
        .post("/api/users/register")
        .set("Authorization", "Bearer dummy.token")
        .send({ name: "Test User" });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty("name", "Test User");
      expect(res.body.avatar_url).toBe("unchanged.png");
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
      expect(res.body).toHaveProperty("message", "Kein Token übergeben.");
    });

    it("401 bei falschem Header-Format", async () => {
      const res = await request(app)
        .get("/api/users/me")
        .set("Authorization", "Invalid token");
      expect(res.statusCode).toBe(401);
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
    await prisma.$disconnect();
  });
});
