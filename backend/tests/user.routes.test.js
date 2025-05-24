const request = require("supertest");
const express = require("express");

// 1) Erstelle Deinen Mock einmal
const mockVerifyIdToken = jest.fn();

// 2) Mock das gesamte Modul ../app/firebase
jest.mock("../app/firebase", () => ({
  auth: () => ({
    verifyIdToken: mockVerifyIdToken
  })
}));

// Jetzt holen wir unser gemocktes Modul
const admin = require("../app/firebase");
const userRoutes = require("../app/routes/user.routes");

describe("User-Routes", () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());
    app.use("/api/users", userRoutes);
  });

  describe("POST /api/users/register", () => {
    it("returns 201 (stub)", async () => {
      const res = await request(app)
        .post("/api/users/register")
        .send({ email: "foo@bar.com", password: "secret" });
      expect(res.statusCode).toBe(201);
      expect(res.body).toEqual({ message: "User registered (stub)" });
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
        .set("Authorization", "BadToken xyz");
      expect(res.statusCode).toBe(401);
    });

    it("200 mit gültigem Token", async () => {
      const fakeDecoded = { uid: "u1", email: "alice@example.com" };
      mockVerifyIdToken.mockResolvedValueOnce(fakeDecoded);

      const res = await request(app)
        .get("/api/users/me")
        .set("Authorization", "Bearer valid.jwt.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual({ user: fakeDecoded });
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
});
