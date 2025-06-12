const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();

exports.getAllWithOptions = async () => {
  return prisma.preference_question.findMany({
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
};

exports.setUserPreferences = async (userId, optionKeys) => {
  // alle Optionen mit passendem key holen
  const allOptions = await prisma.preference_option.findMany({
    where: {
      key: { in: optionKeys },
    },
  });

  // alte löschen
  await prisma.user_preference.deleteMany({
    where: { user_id: userId },
  });

  // neue speichern
  const data = allOptions.map((opt) => ({
    user_id: userId,
    option_id: opt.id,
  }));

  if (data.length > 0) {
    await prisma.user_preference.createMany({ data });
  }
};
