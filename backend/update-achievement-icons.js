const { PrismaClient } = require('./app/generated/prisma');

const prisma = new PrismaClient();

const iconMappings = [
  {
    key: '10_recipes',
    icon: 'restaurant'
  },
  {
    key: '5_photos',
    icon: 'camera_alt'
  },
  {
    key: 'first_favorite',
    icon: 'favorite'
  },
  {
    key: '10_favorites',
    icon: 'star'
  },
  {
    key: 'first_rating',
    icon: 'star_rate'
  },
  {
    key: '5_ratings',
    icon: 'rate_review'
  },
  {
    key: 'first_recipe',
    icon: 'chef'
  },
  {
    key: '5_own_recipes',
    icon: 'edit_note'
  },
  {
    key: 'first_share',
    icon: 'share'
  },
  {
    key: '10_shares',
    icon: 'campaign'
  }
];

async function updateAchievementIcons() {
  try {
    console.log('Starte Icon-Update...');
    
    for (const mapping of iconMappings) {
      await prisma.achievement.update({
        where: { key: mapping.key },
        data: { icon: mapping.icon }
      });
      console.log(`✅ Icon für "${mapping.key}" auf "${mapping.icon}" aktualisiert`);
    }
    
    console.log('🎉 Icon-Update abgeschlossen!');
  } catch (error) {
    console.error('❌ Fehler beim Icon-Update:', error);
  } finally {
    await prisma.$disconnect();
  }
}

updateAchievementIcons(); 