const prisma = require('../prisma');

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

exports.getUserPreferences = async (userId) => {
  const userPreferences = await prisma.user_preference.findMany({
    where: { user_id: userId },
    include: {
      preference_option: {
        include: {
          preference_question: true,
        },
      },
    },
  });

  // Gruppiere Präferenzen nach Fragen
  const preferencesByQuestion = {};
  userPreferences.forEach((pref) => {
    const questionKey = pref.preference_option.preference_question.key;
    if (!preferencesByQuestion[questionKey]) {
      preferencesByQuestion[questionKey] = {
        questionKey: questionKey,
        questionLabel: pref.preference_option.preference_question.label,
        selectedOptions: [],
      };
    }
    preferencesByQuestion[questionKey].selectedOptions.push({
      key: pref.preference_option.key,
      label: pref.preference_option.label,
      icon: pref.preference_option.icon,
    });
  });

  // Gib nur plain JS-Objekte zurück
  return Object.values(preferencesByQuestion).map(q => ({
    ...q,
    selectedOptions: q.selectedOptions.map(opt => ({
      key: opt.key,
      label: opt.label,
      icon: opt.icon,
    })),
  }));
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
