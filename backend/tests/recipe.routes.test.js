const mockVerifyIdToken = jest.fn();

jest.mock("../app/firebase", () => ({
  auth: () => ({
    verifyIdToken: mockVerifyIdToken,
  }),
}));

const mockFindMany = jest.fn();
const mockFindUnique = jest.fn();
const mockCreate = jest.fn();
const mockUpdate = jest.fn();
const mockDelete = jest.fn();

jest.mock("../app/generated/prisma", () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => ({
      recipes: {
        findMany: mockFindMany,
        findUnique: mockFindUnique,
        create: mockCreate,
        update: mockUpdate,
        delete: mockDelete,
      },
      user_favorites: {
        findMany: mockFindMany,
        findUnique: mockFindUnique,
        create: mockCreate,
        delete: mockDelete,
      },
      user_ratings: {
        findMany: mockFindMany,
        findUnique: mockFindUnique,
        create: mockCreate,
        update: mockUpdate,
      },
      $disconnect: jest.fn(),
    })),
  };
});

// Mock recipeManagementService
const mockGetOwnRecipesForUser = jest.fn();
const mockGetOrCreateRecipeInDb = jest.fn();
const mockAddFavoriteRecipeByRecipeId = jest.fn();
const mockRemoveFavoriteRecipe = jest.fn();
const mockGetFavoriteRecipesForUser = jest.fn();
const mockIsRecipeFavoritedByUser = jest.fn();
const mockAddOrUpdateRecipeRating = jest.fn();
const mockGetUserRecipeRating = jest.fn();
const mockGetAverageRecipeRating = jest.fn();
const mockGetInternalRecipeDetails = jest.fn();

jest.mock("../app/services/recipeManagementService", () => ({
  getOwnRecipesForUser: mockGetOwnRecipesForUser,
  getOrCreateRecipeInDb: mockGetOrCreateRecipeInDb,
  addFavoriteRecipeByRecipeId: mockAddFavoriteRecipeByRecipeId,
  removeFavoriteRecipe: mockRemoveFavoriteRecipe,
  getFavoriteRecipesForUser: mockGetFavoriteRecipesForUser,
  isRecipeFavoritedByUser: mockIsRecipeFavoritedByUser,
  addOrUpdateRecipeRating: mockAddOrUpdateRecipeRating,
  getUserRecipeRating: mockGetUserRecipeRating,
  getAverageRecipeRating: mockGetAverageRecipeRating,
  getInternalRecipeDetails: mockGetInternalRecipeDetails,
}));

// Mock mediaService
const mockGetSignedDownloadUrl = jest.fn();

jest.mock("../app/services/media.service", () => ({
  getSignedDownloadUrl: mockGetSignedDownloadUrl,
}));

const request = require("supertest");
const express = require("express");
const { PrismaClient } = require("../app/generated/prisma");
const prisma = new PrismaClient();

describe("Recipe-Routes", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());

    const recipeRoutes = require("../app/routes/recipe.routes");
    app.use("/api/recipes", recipeRoutes);
  });

  describe("GET /api/recipes/mine", () => {
    it("returns user's own recipes", async () => {
      // Mock Firebase authentication
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      // Mock own recipes data
      const mockOwnRecipes = [
        {
          id: "1",
          title: "My Pasta Recipe",
          image_url: "recipes/pasta.jpg",
          created_at: new Date(),
          updated_at: new Date()
        },
        {
          id: "2",
          title: "My Pizza Recipe", 
          image_url: "recipes/pizza.jpg",
          created_at: new Date(),
          updated_at: new Date()
        }
      ];

      mockGetOwnRecipesForUser.mockResolvedValueOnce(mockOwnRecipes);
      mockGetSignedDownloadUrl
        .mockResolvedValueOnce("https://signed-url.com/pasta.jpg")
        .mockResolvedValueOnce("https://signed-url.com/pizza.jpg");

      const res = await request(app)
        .get("/api/recipes/mine")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveLength(2);
      
      expect(res.body[0]).toEqual({
        id: "1",
        title: "My Pasta Recipe",
        imageUrl: "https://signed-url.com/pasta.jpg",
        image_url: "recipes/pasta.jpg",
        created_at: expect.any(String),
        updated_at: expect.any(String)
      });

      expect(res.body[1]).toEqual({
        id: "2",
        title: "My Pizza Recipe",
        imageUrl: "https://signed-url.com/pizza.jpg",
        image_url: "recipes/pizza.jpg",
        created_at: expect.any(String),
        updated_at: expect.any(String)
      });
    });

    it("returns 401 without authorization header", async () => {
      const res = await request(app).get("/api/recipes/mine");
      expect(res.statusCode).toBe(401);
    });

    it("returns 401 with invalid token", async () => {
      mockVerifyIdToken.mockRejectedValueOnce(new Error("Invalid token"));
      
      const res = await request(app)
        .get("/api/recipes/mine")
        .set("Authorization", "Bearer invalid.token");

      expect(res.statusCode).toBe(401);
    });

    it("returns empty array when user has no recipes", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      mockGetOwnRecipesForUser.mockResolvedValueOnce([]);

      const res = await request(app)
        .get("/api/recipes/mine")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual([]);
    });

    it("handles recipes with external image URLs", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      const mockOwnRecipes = [
        {
          id: "1",
          title: "External Image Recipe",
          image_url: "https://external.com/image.jpg", // External URL
          created_at: new Date(),
          updated_at: new Date()
        }
      ];

      mockGetOwnRecipesForUser.mockResolvedValueOnce(mockOwnRecipes);
      mockGetSignedDownloadUrl.mockResolvedValueOnce("https://external.com/image.jpg");

      const res = await request(app)
        .get("/api/recipes/mine")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body[0].imageUrl).toBe("https://external.com/image.jpg");
      expect(res.body[0].image_url).toBe("https://external.com/image.jpg");
    });
  });

  describe("GET /api/recipes/favorites", () => {
    it("returns user's favorite recipes", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      const mockFavoriteRecipes = [
        {
          id: "1",
          title: "Favorite Pasta",
          image_url: "https://example.com/pasta.jpg"
        }
      ];

      mockGetFavoriteRecipesForUser.mockResolvedValueOnce(mockFavoriteRecipes);

      const res = await request(app)
        .get("/api/recipes/favorites")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual(mockFavoriteRecipes);
    });
  });

  describe("GET /api/recipes/:recipeId/isFavorited", () => {
    it("returns favorite status when recipe is favorited", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      const mockFavorite = {
        id: "favorite1",
        user_id: "abc123",
        recipe_id: "recipe1"
      };

      mockIsRecipeFavoritedByUser.mockResolvedValueOnce(mockFavorite);

      const res = await request(app)
        .get("/api/recipes/recipe1/isFavorited")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual(mockFavorite);
    });

    it("returns 404 when recipe is not favorited", async () => {
      mockVerifyIdToken.mockResolvedValueOnce({
        uid: "abc123",
        email: "test@example.com"
      });

      mockIsRecipeFavoritedByUser.mockResolvedValueOnce(null);

      const res = await request(app)
        .get("/api/recipes/recipe1/isFavorited")
        .set("Authorization", "Bearer valid.token");

      expect(res.statusCode).toBe(404);
      expect(res.body.message).toBe("Recipe not favorited by this user.");
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });
}); 