const mockVerifyIdToken = jest.fn();

jest.mock("../app/firebase", () => ({
  auth: () => ({
    verifyIdToken: mockVerifyIdToken,
  }),
}));

const mockFindMany = jest.fn();
const mockFindUnique = jest.fn();

jest.mock("../app/generated/prisma", () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => ({
      achievement: {
        findMany: mockFindMany,
        findUnique: mockFindUnique,
      },
      user_achievement: {
        findMany: mockFindMany,
        findUnique: mockFindUnique,
      },
      $disconnect: jest.fn(),
    })),
  };
});

const request = require("supertest");
const express = require("express");
const { PrismaClient } = require("../app/generated/prisma");
const prisma = new PrismaClient();

describe("Achievement-Routes", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());

    const achievementRoutes = require("../app/routes/achievement.route");
    app.use("/api/achievements", achievementRoutes);
  });

  describe("GET /api/achievements", () => {
    it("returns achievements with status for authenticated user", async () => {
      // Mock Firebase authentication
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      // Mock achievements data
      const mockAchievements = [
        {
          id: "1",
          key: "first_recipe",
          title: "First Recipe",
          description: "Create your first recipe",
          icon: "🍳",
          created_at: new Date()
        },
        {
          id: "2", 
          key: "ten_recipes",
          title: "Recipe Master",
          description: "Create 10 recipes",
          icon: "👨‍🍳",
          created_at: new Date()
        }
      ];

      // Mock unlocked achievements
      const mockUnlockedAchievements = [
        { achievement_id: "1" }
      ];

      // Setup mocks
      mockFindMany
        .mockResolvedValueOnce(mockAchievements) // First call for all achievements
        .mockResolvedValueOnce(mockUnlockedAchievements); // Second call for unlocked achievements

      const res = await request(app)
        .get("/api/achievements")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveLength(2);
      
      // Check first achievement (unlocked)
      expect(res.body[0]).toEqual({
        id: "1",
        key: "first_recipe", 
        title: "First Recipe",
        description: "Create your first recipe",
        icon: "🍳",
        unlocked: true
      });

      // Check second achievement (locked)
      expect(res.body[1]).toEqual({
        id: "2",
        key: "ten_recipes",
        title: "Recipe Master", 
        description: "Create 10 recipes",
        icon: "👨‍🍳",
        unlocked: false
      });
    });

    it("returns 401 without authorization header", async () => {
      const res = await request(app).get("/api/achievements");
      expect(res.statusCode).toBe(401);
    });

    it("returns 401 with invalid token", async () => {
      mockVerifyIdToken.mockRejectedValueOnce(new Error("Invalid token"));
      
      const res = await request(app)
        .get("/api/achievements")
        .set("Authorization", "Bearer invalid.token");

      expect(res.statusCode).toBe(401);
    });

    it("returns empty array when no achievements exist", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      mockFindMany
        .mockResolvedValueOnce([]) // No achievements
        .mockResolvedValueOnce([]); // No unlocked achievements

      const res = await request(app)
        .get("/api/achievements")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual([]);
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });
}); 