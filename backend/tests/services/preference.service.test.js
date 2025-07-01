const preferenceService = require('../../app/services/preference.service');

// Mock Prisma
jest.mock('../../app/prisma', () => ({
  preference_question: {
    findMany: jest.fn(),
  },
  user_preference: {
    findMany: jest.fn(),
    deleteMany: jest.fn(),
    createMany: jest.fn(),
  },
  preference_option: {
    findMany: jest.fn(),
  },
}));

// Import mocked prisma
const prisma = require('../../app/prisma');

describe('Preference Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllWithOptions', () => {
    it('should return all preference questions with options', async () => {
      const mockQuestions = [
        {
          id: 1,
          key: 'cuisine',
          label: 'What cuisine do you prefer?',
          options: [
            { key: 'italian', label: 'Italian', icon: '🍝' },
            { key: 'asian', label: 'Asian', icon: '🍜' },
          ],
        },
      ];

      prisma.preference_question.findMany.mockResolvedValue(mockQuestions);

      const result = await preferenceService.getAllWithOptions();

      expect(prisma.preference_question.findMany).toHaveBeenCalledWith({
        include: {
          options: {
            select: {
              key: true,
              label: true,
              icon: true,
            },
          },
        },
      });
      expect(result).toEqual(mockQuestions);
    });

    it('should handle empty results', async () => {
      prisma.preference_question.findMany.mockResolvedValue([]);

      const result = await preferenceService.getAllWithOptions();

      expect(result).toEqual([]);
    });

    it('should handle database errors', async () => {
      prisma.preference_question.findMany.mockRejectedValue(new Error('Database error'));

      await expect(preferenceService.getAllWithOptions()).rejects.toThrow('Database error');
    });
  });

  describe('getUserPreferences', () => {
    it('should return user preferences grouped by question', async () => {
      const mockUserPreferences = [
        {
          preference_option: {
            key: 'italian',
            label: 'Italian',
            icon: '🍝',
            preference_question: {
              key: 'cuisine',
              label: 'What cuisine do you prefer?',
            },
          },
        },
        {
          preference_option: {
            key: 'spicy',
            label: 'Spicy',
            icon: '🌶️',
            preference_question: {
              key: 'spice_level',
              label: 'How spicy do you like your food?',
            },
          },
        },
      ];

      prisma.user_preference.findMany.mockResolvedValue(mockUserPreferences);

      const result = await preferenceService.getUserPreferences('user-123');

      expect(prisma.user_preference.findMany).toHaveBeenCalledWith({
        where: { user_id: 'user-123' },
        include: {
          preference_option: {
            include: {
              preference_question: true,
            },
          },
        },
      });

      expect(result).toEqual([
        {
          questionKey: 'cuisine',
          questionLabel: 'What cuisine do you prefer?',
          selectedOptions: [
            { key: 'italian', label: 'Italian', icon: '🍝' },
          ],
        },
        {
          questionKey: 'spice_level',
          questionLabel: 'How spicy do you like your food?',
          selectedOptions: [
            { key: 'spicy', label: 'Spicy', icon: '🌶️' },
          ],
        },
      ]);
    });

    it('should handle user with no preferences', async () => {
      prisma.user_preference.findMany.mockResolvedValue([]);

      const result = await preferenceService.getUserPreferences('user-123');

      expect(result).toEqual([]);
    });

    it('should handle database errors', async () => {
      prisma.user_preference.findMany.mockRejectedValue(new Error('Database error'));

      await expect(preferenceService.getUserPreferences('user-123')).rejects.toThrow('Database error');
    });
  });

  describe('setUserPreferences', () => {
    it('should set user preferences successfully', async () => {
      const mockOptions = [
        { id: 1, key: 'italian' },
        { id: 2, key: 'spicy' },
      ];

      prisma.preference_option.findMany.mockResolvedValue(mockOptions);
      prisma.user_preference.deleteMany.mockResolvedValue({ count: 2 });
      prisma.user_preference.createMany.mockResolvedValue({ count: 2 });

      await preferenceService.setUserPreferences('user-123', ['italian', 'spicy']);

      expect(prisma.preference_option.findMany).toHaveBeenCalledWith({
        where: {
          key: { in: ['italian', 'spicy'] },
        },
      });

      expect(prisma.user_preference.deleteMany).toHaveBeenCalledWith({
        where: { user_id: 'user-123' },
      });

      expect(prisma.user_preference.createMany).toHaveBeenCalledWith({
        data: [
          { user_id: 'user-123', option_id: 1 },
          { user_id: 'user-123', option_id: 2 },
        ],
      });
    });

    it('should handle empty option keys', async () => {
      prisma.preference_option.findMany.mockResolvedValue([]);
      prisma.user_preference.deleteMany.mockResolvedValue({ count: 0 });

      await preferenceService.setUserPreferences('user-123', []);

      expect(prisma.user_preference.deleteMany).toHaveBeenCalledWith({
        where: { user_id: 'user-123' },
      });

      expect(prisma.user_preference.createMany).not.toHaveBeenCalled();
    });

    it('should handle invalid option keys', async () => {
      prisma.preference_option.findMany.mockResolvedValue([]);
      prisma.user_preference.deleteMany.mockResolvedValue({ count: 0 });

      await preferenceService.setUserPreferences('user-123', ['invalid-key']);

      expect(prisma.user_preference.deleteMany).toHaveBeenCalledWith({
        where: { user_id: 'user-123' },
      });

      expect(prisma.user_preference.createMany).not.toHaveBeenCalled();
    });

    it('should handle database errors', async () => {
      prisma.preference_option.findMany.mockRejectedValue(new Error('Database error'));

      await expect(preferenceService.setUserPreferences('user-123', ['italian'])).rejects.toThrow('Database error');
    });
  });
}); 