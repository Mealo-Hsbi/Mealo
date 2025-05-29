// Ingredients.dart (Aktualisiert)

import '../models/ingredient.dart';

final List<Ingredient> allIngredients = [
  Ingredient(
    id: 'tomato',
    name: 'Tomato',
    imageUrl: 'assets/images/ingredients/tomato.webp',
    aliases: ['tomatos', 'tomatoes'], // Häufige Fehler/Plurale
  ),
  Ingredient(
    id: 'onion',
    name: 'Onion',
    imageUrl: 'assets/images/ingredients/onion.webp',
    aliases: ['onions'],
  ),
  Ingredient(
    id: 'garlic',
    name: 'Garlic',
    imageUrl: 'assets/images/ingredients/garlic.webp',
    aliases: ['garlics'], // Weniger häufig, aber zur Sicherheit
  ),
  Ingredient(
    id: 'carrot',
    name: 'Carrot',
    imageUrl: 'assets/images/ingredients/carrot.webp',
    aliases: ['carrots'],
  ),
  Ingredient(
    id: 'potato',
    name: 'Potato',
    imageUrl: 'assets/images/ingredients/potato.webp',
    aliases: ['potatos', 'potatoes'],
  ),
  Ingredient(
    id: 'bell_pepper',
    name: 'Bell Pepper',
    imageUrl: 'assets/images/ingredients/bell_pepper.webp',
    aliases: ['bell peppers', 'paprika', 'paprikas', 'sweet pepper', 'sweet peppers'], // Gängige Synonyme/Plurale
  ),
  Ingredient(
    id: 'cucumber',
    name: 'Cucumber',
    imageUrl: 'assets/images/ingredients/cucumber.webp',
    aliases: ['cucumbers'],
  ),
  Ingredient(
    id: 'lettuce',
    name: 'Lettuce',
    imageUrl: 'assets/images/ingredients/lettuce.webp',
    aliases: ['lettuces'], // Selten, aber möglich
  ),
  Ingredient(
    id: 'mushroom',
    name: 'Mushroom',
    imageUrl: 'assets/images/ingredients/mushroom.webp',
    aliases: ['mushrooms'],
  ),
  Ingredient(
    id: 'egg',
    name: 'Egg',
    imageUrl: 'assets/images/ingredients/egg.webp',
    aliases: ['eggs'],
  ),
  Ingredient(
    id: 'cheese',
    name: 'Cheese',
    imageUrl: 'assets/images/ingredients/cheese.webp',
    aliases: ['cheeses'], // Weniger häufig
  ),
  Ingredient(
    id: 'milk',
    name: 'Milk',
    imageUrl: 'assets/images/ingredients/milk.webp',
    aliases: [], // Keine offensichtlichen Aliase
  ),
  Ingredient(
    id: 'butter',
    name: 'Butter',
    imageUrl: 'assets/images/ingredients/butter.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'flour',
    name: 'Flour',
    imageUrl: 'assets/images/ingredients/flour.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'sugar',
    name: 'Sugar',
    imageUrl: 'assets/images/ingredients/sugar.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'salt',
    name: 'Salt',
    imageUrl: 'assets/images/ingredients/salt.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'pepper',
    name: 'Pepper',
    imageUrl: 'assets/images/ingredients/pepper.webp',
    aliases: ['peppers'], // falls schwarzer/weißer Pfeffer gemeint ist
  ),
  Ingredient(
    id: 'chicken_breast',
    name: 'Chicken Breast',
    imageUrl: 'assets/images/ingredients/chicken_breast.webp',
    aliases: ['chicken breasts', 'chicken'], // Allgemeiner "chicken"
  ),
  Ingredient(
    id: 'ground_beef',
    name: 'Ground Beef',
    imageUrl: 'assets/images/ingredients/ground_beef.webp',
    aliases: ['minced meat', 'minced beef', 'ground meat', 'beef'], // Synonyme
  ),
  Ingredient(
    id: 'salmon',
    name: 'Salmon',
    imageUrl: 'assets/images/ingredients/salmon.webp',
    aliases: ['salmons'],
  ),

  // Erweiterung der Liste:
  Ingredient(
    id: 'basil',
    name: 'Basil',
    imageUrl: 'assets/images/ingredients/basil.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'oregano',
    name: 'Oregano',
    imageUrl: 'assets/images/ingredients/oregano.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'parsley',
    name: 'Parsley',
    imageUrl: 'assets/images/ingredients/parsley.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'thyme',
    name: 'Thyme',
    imageUrl: 'assets/images/ingredients/thyme.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'rosemary',
    name: 'Rosemary',
    imageUrl: 'assets/images/ingredients/rosemary.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'spinach',
    name: 'Spinach',
    imageUrl: 'assets/images/ingredients/spinach.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'broccoli',
    name: 'Broccoli',
    imageUrl: 'assets/images/ingredients/broccoli.webp',
    aliases: ['broccolis'],
  ),
  Ingredient(
    id: 'corn',
    name: 'Corn',
    imageUrl: 'assets/images/ingredients/corn.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'green_pea',
    name: 'Green Peas', // Name im Plural, ID im Singular
    imageUrl: 'assets/images/ingredients/green_pea.webp',
    aliases: ['green peas', 'pea', 'peas'], // Modell könnte "green peas" liefern
  ),
  Ingredient(
    id: 'eggplant',
    name: 'Eggplant',
    imageUrl: 'assets/images/ingredients/eggplant.webp',
    aliases: ['eggplants', 'aubergine', 'aubergines'], // Synonyme/Plurale
  ),
  Ingredient(
    id: 'zucchini',
    name: 'Zucchini',
    imageUrl: 'assets/images/ingredients/zucchini.webp',
    aliases: ['zucchinis', 'courgette', 'courgettes'], // Synonyme/Plurale
  ),
  Ingredient(
    id: 'cabbage',
    name: 'Cabbage',
    imageUrl: 'assets/images/ingredients/cabbage.webp',
    aliases: ['cabbages'],
  ),
  Ingredient(
    id: 'beef_steak',
    name: 'Beef Steak',
    imageUrl: 'assets/images/ingredients/beef_steak.webp',
    aliases: ['beef steaks', 'steak', 'steaks'], // Synonyme
  ),
  Ingredient(
    id: 'pork',
    name: 'Pork',
    imageUrl: 'assets/images/ingredients/pork.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'bacon',
    name: 'Bacon',
    imageUrl: 'assets/images/ingredients/bacon.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'shrimp',
    name: 'Shrimp',
    imageUrl: 'assets/images/ingredients/shrimp.webp',
    aliases: ['shrimps', 'prawn', 'prawns'], // Synonyme/Plurale
  ),
  Ingredient(
    id: 'tofu',
    name: 'Tofu',
    imageUrl: 'assets/images/ingredients/tofu.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'rice',
    name: 'Rice',
    imageUrl: 'assets/images/ingredients/rice.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'pasta',
    name: 'Pasta',
    imageUrl: 'assets/images/ingredients/pasta.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'bread',
    name: 'Bread',
    imageUrl: 'assets/images/ingredients/bread.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'lemon',
    name: 'Lemon',
    imageUrl: 'assets/images/ingredients/lemon.webp',
    aliases: ['lemons'],
  ),
  Ingredient(
    id: 'lime',
    name: 'Lime',
    imageUrl: 'assets/images/ingredients/lime.webp',
    aliases: ['limes'],
  ),
  Ingredient(
    id: 'apple',
    name: 'Apple',
    imageUrl: 'assets/images/ingredients/apple.webp',
    aliases: ['apples'],
  ),
  Ingredient(
    id: 'banana',
    name: 'Banana',
    imageUrl: 'assets/images/ingredients/banana.webp',
    aliases: ['bananas'],
  ),
  Ingredient(
    id: 'orange',
    name: 'Orange',
    imageUrl: 'assets/images/ingredients/orange.webp',
    aliases: ['oranges'],
  ),
  Ingredient(
    id: 'honey',
    name: 'Honey',
    imageUrl: 'assets/images/ingredients/honey.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'cinnamon',
    name: 'Cinnamon',
    imageUrl: 'assets/images/ingredients/cinnamon.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'cumin',
    name: 'Cumin',
    imageUrl: 'assets/images/ingredients/cumin.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'coriander',
    name: 'Coriander',
    imageUrl: 'assets/images/ingredients/coriander.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'turmeric',
    name: 'Turmeric',
    imageUrl: 'assets/images/ingredients/turmeric.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'paprika_powder',
    name: 'Paprika Powder',
    imageUrl: 'assets/images/ingredients/paprika_powder.webp',
    aliases: ['paprika', 'red pepper powder'], // Allgemeine Bezeichnung
  ),
  Ingredient(
    id: 'nutmeg',
    name: 'Nutmeg',
    imageUrl: 'assets/images/ingredients/nutmeg.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'cloves',
    name: 'Cloves',
    imageUrl: 'assets/images/ingredients/cloves.webp',
    aliases: ['clove'], // Singular
  ),
  Ingredient(
    id: 'cardamom',
    name: 'Cardamom',
    imageUrl: 'assets/images/ingredients/cardamom.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'bay_leaf',
    name: 'Bay Leaf',
    imageUrl: 'assets/images/ingredients/bay_leaf.webp',
    aliases: ['bay leaves'], // Plural
  ),
  Ingredient(
    id: 'chili_flakes',
    name: 'Chili Flakes',
    imageUrl: 'assets/images/ingredients/chili_flakes.webp',
    aliases: ['chilli flakes', 'red pepper flakes'],
  ),
  Ingredient(
    id: 'ginger',
    name: 'Ginger',
    imageUrl: 'assets/images/ingredients/ginger.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'mustard_seeds',
    name: 'Mustard Seeds',
    imageUrl: 'assets/images/ingredients/mustard_seeds.webp',
    aliases: ['mustard seed'], // Singular
  ),
  Ingredient(
    id: 'saffron',
    name: 'Saffron',
    imageUrl: 'assets/images/ingredients/saffron.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'strawberry',
    name: 'Strawberry',
    imageUrl: 'assets/images/ingredients/strawberry.webp',
    aliases: ['strawberries'],
  ),
  Ingredient(
    id: 'blueberry',
    name: 'Blueberry',
    imageUrl: 'assets/images/ingredients/blueberry.webp',
    aliases: ['blueberries'],
  ),
  Ingredient(
    id: 'raspberry',
    name: 'Raspberry',
    imageUrl: 'assets/images/ingredients/raspberry.webp',
    aliases: ['raspberries'],
  ),
  Ingredient(
    id: 'blackberry',
    name: 'Blackberry',
    imageUrl: 'assets/images/ingredients/blackberry.webp',
    aliases: ['blackberries'],
  ),
  Ingredient(
    id: 'pineapple',
    name: 'Pineapple',
    imageUrl: 'assets/images/ingredients/pineapple.webp',
    aliases: ['pineapples'],
  ),
  Ingredient(
    id: 'mango',
    name: 'Mango',
    imageUrl: 'assets/images/ingredients/mango.webp',
    aliases: ['mangoes'],
  ),
  Ingredient(
    id: 'peach',
    name: 'Peach',
    imageUrl: 'assets/images/ingredients/peach.webp',
    aliases: ['peaches'],
  ),
  Ingredient(
    id: 'pear',
    name: 'Pear',
    imageUrl: 'assets/images/ingredients/pear.webp',
    aliases: ['pears'],
  ),
  Ingredient(
    id: 'cherry',
    name: 'Cherry',
    imageUrl: 'assets/images/ingredients/cherry.webp',
    aliases: ['cherries'],
  ),
  Ingredient(
    id: 'grape',
    name: 'Grape',
    imageUrl: 'assets/images/ingredients/grape.webp',
    aliases: ['grapes'],
  ),
  Ingredient(
    id: 'watermelon',
    name: 'Watermelon',
    imageUrl: 'assets/images/ingredients/watermelon.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'kiwi',
    name: 'Kiwi',
    imageUrl: 'assets/images/ingredients/kiwi.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'papaya',
    name: 'Papaya',
    imageUrl: 'assets/images/ingredients/papaya.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'pomegranate',
    name: 'Pomegranate',
    imageUrl: 'assets/images/ingredients/pomegranate.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'coconut',
    name: 'Coconut',
    imageUrl: 'assets/images/ingredients/coconut.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'tuna',
    name: 'Tuna',
    imageUrl: 'assets/images/ingredients/tuna.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'cod',
    name: 'Cod',
    imageUrl: 'assets/images/ingredients/cod.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'mussel',
    name: 'Mussels', // Name im Plural
    imageUrl: 'assets/images/ingredients/mussel.webp',
    aliases: ['mussels'], // Alias für die Pluralform
  ),
  Ingredient(
    id: 'scallop',
    name: 'Scallops', // Name im Plural
    imageUrl: 'assets/images/ingredients/scallop.webp',
    aliases: ['scallops'], // Alias für die Pluralform
  ),
  Ingredient(
    id: 'crab',
    name: 'Crab',
    imageUrl: 'assets/images/ingredients/crab.webp',
    aliases: ['crabs'],
  ),
  Ingredient(
    id: 'lobster',
    name: 'Lobster',
    imageUrl: 'assets/images/ingredients/lobster.webp',
    aliases: ['lobsters'],
  ),
  Ingredient(
    id: 'octopus',
    name: 'Octopus',
    imageUrl: 'assets/images/ingredients/octopus.webp',
    aliases: ['octopi', 'octopuses'], // Mehrere Plurale möglich
  ),
  Ingredient(
    id: 'squid',
    name: 'Squid',
    imageUrl: 'assets/images/ingredients/squid.webp',
    aliases: ['squids'],
  ),
  Ingredient(
    id: 'anchovy',
    name: 'Anchovy',
    imageUrl: 'assets/images/ingredients/anchovy.webp',
    aliases: ['anchovies'],
  ),
  Ingredient(
    id: 'clam',
    name: 'Clams', // Name im Plural
    imageUrl: 'assets/images/ingredients/clam.webp',
    aliases: ['clams'], // Alias für die Pluralform
  ),
  Ingredient(
    id: 'lime_juice',
    name: 'Lime Juice',
    imageUrl: 'assets/images/ingredients/lime_juice.webp',
    aliases: [], // Keine offensichtlichen Aliase, aber klar und spezifisch
  ),
  Ingredient(
    id: 'chicken_thigh',
    name: 'Chicken Thigh',
    imageUrl: 'assets/images/ingredients/chicken_thigh.webp',
    aliases: ['chicken thighs'],
  ),
  Ingredient(
    id: 'pork_chop',
    name: 'Pork Chop',
    imageUrl: 'assets/images/ingredients/pork_chop.webp',
    aliases: ['pork chops'],
  ),
  Ingredient(
    id: 'sausage',
    name: 'Sausage',
    imageUrl: 'assets/images/ingredients/sausage.webp',
    aliases: ['sausages'],
  ),
  Ingredient(
    id: 'yogurt',
    name: 'Yogurt',
    imageUrl: 'assets/images/ingredients/yogurt.webp',
    aliases: ['yoghurt'],
  ),
  Ingredient(
    id: 'sour_cream',
    name: 'Sour Cream',
    imageUrl: 'assets/images/ingredients/sour_cream.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'heavy_cream',
    name: 'Heavy Cream',
    imageUrl: 'assets/images/ingredients/heavy_cream.webp',
    aliases: ['whipping cream'],
  ),
  Ingredient(
    id: 'broth',
    name: 'Broth',
    imageUrl: 'assets/images/ingredients/broth.webp',
    aliases: ['stock', 'chicken broth', 'vegetable broth', 'beef broth'], // Allgemeine Begriffe
  ),
  Ingredient(
    id: 'vinegar',
    name: 'Vinegar',
    imageUrl: 'assets/images/ingredients/vinegar.webp',
    aliases: ['apple cider vinegar', 'white vinegar', 'balsamic vinegar'], // Spezifischere Varianten
  ),
  Ingredient(
    id: 'olive_oil',
    name: 'Olive Oil',
    imageUrl: 'assets/images/ingredients/olive_oil.webp',
    aliases: ['oil'], // Wenn nur "oil" erkannt wird und primär Olivenöl gemeint ist
  ),
  Ingredient(
    id: 'soy_sauce',
    name: 'Soy Sauce',
    imageUrl: 'assets/images/ingredients/soy_sauce.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'honey_mustard',
    name: 'Honey Mustard',
    imageUrl: 'assets/images/ingredients/honey_mustard.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'ketchup',
    name: 'Ketchup',
    imageUrl: 'assets/images/ingredients/ketchup.webp',
    aliases: ['tomato ketchup'],
  ),
  Ingredient(
    id: 'mayonnaise',
    name: 'Mayonnaise',
    imageUrl: 'assets/images/ingredients/mayonnaise.webp',
    aliases: ['mayo'],
  ),
  Ingredient(
    id: 'mustard',
    name: 'Mustard',
    imageUrl: 'assets/images/ingredients/mustard.webp',
    aliases: ['dijon mustard', 'yellow mustard'],
  ),
  Ingredient(
    id: 'bbq_sauce',
    name: 'BBQ Sauce',
    imageUrl: 'assets/images/ingredients/bbq_sauce.webp',
    aliases: ['barbecue sauce'],
  ),
  Ingredient(
    id: 'oats',
    name: 'Oats', // Oft als Plural oder Sammelbegriff
    imageUrl: 'assets/images/ingredients/oats.webp',
    aliases: ['oat', 'oatmeal', 'rolled oats'],
  ),
  Ingredient(
    id: 'quinoa',
    name: 'Quinoa',
    imageUrl: 'assets/images/ingredients/quinoa.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'lentil',
    name: 'Lentils', // Häufiger als Plural verwendet
    imageUrl: 'assets/images/ingredients/lentil.webp',
    aliases: ['lentils'],
  ),
  Ingredient(
    id: 'chickpea',
    name: 'Chickpeas', // Häufiger als Plural verwendet
    imageUrl: 'assets/images/ingredients/chickpea.webp',
    aliases: ['chickpeas', 'garbanzo bean', 'garbanzo beans'],
  ),
];
