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
  
  // Additional ingredients for image detection
  Ingredient(
    id: 'asparagus',
    name: 'Asparagus',
    imageUrl: 'assets/images/ingredients/asparagus.webp',
    aliases: ['asparaguses'],
  ),
  Ingredient(
    id: 'artichoke',
    name: 'Artichoke',
    imageUrl: 'assets/images/ingredients/artichoke.webp',
    aliases: ['artichokes'],
  ),
  Ingredient(
    id: 'avocado',
    name: 'Avocado',
    imageUrl: 'assets/images/ingredients/avocado.webp',
    aliases: ['avocados'],
  ),
  Ingredient(
    id: 'beetroot',
    name: 'Beetroot',
    imageUrl: 'assets/images/ingredients/beetroot.webp',
    aliases: ['beet', 'beets', 'beetroots'],
  ),
  Ingredient(
    id: 'celery',
    name: 'Celery',
    imageUrl: 'assets/images/ingredients/celery.webp',
    aliases: ['celery stalks'],
  ),
  Ingredient(
    id: 'radish',
    name: 'Radish',
    imageUrl: 'assets/images/ingredients/radish.webp',
    aliases: ['radishes'],
  ),
  Ingredient(
    id: 'turnip',
    name: 'Turnip',
    imageUrl: 'assets/images/ingredients/turnip.webp',
    aliases: ['turnips'],
  ),
  Ingredient(
    id: 'parsnip',
    name: 'Parsnip',
    imageUrl: 'assets/images/ingredients/parsnip.webp',
    aliases: ['parsnips'],
  ),
  Ingredient(
    id: 'rutabaga',
    name: 'Rutabaga',
    imageUrl: 'assets/images/ingredients/rutabaga.webp',
    aliases: ['rutabagas', 'swede', 'swedes'],
  ),
  Ingredient(
    id: 'kale',
    name: 'Kale',
    imageUrl: 'assets/images/ingredients/kale.webp',
    aliases: ['curly kale', 'lacinato kale'],
  ),
  Ingredient(
    id: 'chard',
    name: 'Chard',
    imageUrl: 'assets/images/ingredients/chard.webp',
    aliases: ['swiss chard', 'rainbow chard'],
  ),
  Ingredient(
    id: 'collard_greens',
    name: 'Collard Greens',
    imageUrl: 'assets/images/ingredients/collard_greens.webp',
    aliases: ['collards'],
  ),
  Ingredient(
    id: 'arugula',
    name: 'Arugula',
    imageUrl: 'assets/images/ingredients/arugula.webp',
    aliases: ['rocket', 'rucola'],
  ),
  Ingredient(
    id: 'watercress',
    name: 'Watercress',
    imageUrl: 'assets/images/ingredients/watercress.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'endive',
    name: 'Endive',
    imageUrl: 'assets/images/ingredients/endive.webp',
    aliases: ['endives', 'belgian endive'],
  ),
  Ingredient(
    id: 'fennel',
    name: 'Fennel',
    imageUrl: 'assets/images/ingredients/fennel.webp',
    aliases: ['fennel bulb'],
  ),
  Ingredient(
    id: 'leek',
    name: 'Leek',
    imageUrl: 'assets/images/ingredients/leek.webp',
    aliases: ['leeks'],
  ),
  Ingredient(
    id: 'shallot',
    name: 'Shallot',
    imageUrl: 'assets/images/ingredients/shallot.webp',
    aliases: ['shallots'],
  ),
  Ingredient(
    id: 'scallion',
    name: 'Scallion',
    imageUrl: 'assets/images/ingredients/scallion.webp',
    aliases: ['scallions', 'green onion', 'green onions', 'spring onion', 'spring onions'],
  ),
  Ingredient(
    id: 'chive',
    name: 'Chive',
    imageUrl: 'assets/images/ingredients/chive.webp',
    aliases: ['chives'],
  ),
  
  // More vegetables and herbs
  Ingredient(
    id: 'dill',
    name: 'Dill',
    imageUrl: 'assets/images/ingredients/dill.webp',
    aliases: ['dill weed'],
  ),
  Ingredient(
    id: 'mint',
    name: 'Mint',
    imageUrl: 'assets/images/ingredients/mint.webp',
    aliases: ['peppermint', 'spearmint'],
  ),
  Ingredient(
    id: 'sage',
    name: 'Sage',
    imageUrl: 'assets/images/ingredients/sage.webp',
    aliases: ['fresh sage'],
  ),
  Ingredient(
    id: 'marjoram',
    name: 'Marjoram',
    imageUrl: 'assets/images/ingredients/marjoram.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'tarragon',
    name: 'Tarragon',
    imageUrl: 'assets/images/ingredients/tarragon.webp',
    aliases: ['french tarragon'],
  ),
  Ingredient(
    id: 'chamomile',
    name: 'Chamomile',
    imageUrl: 'assets/images/ingredients/chamomile.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'lavender',
    name: 'Lavender',
    imageUrl: 'assets/images/ingredients/lavender.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'lemongrass',
    name: 'Lemongrass',
    imageUrl: 'assets/images/ingredients/lemongrass.webp',
    aliases: ['lemon grass'],
  ),
  Ingredient(
    id: 'kaffir_lime',
    name: 'Kaffir Lime',
    imageUrl: 'assets/images/ingredients/kaffir_lime.webp',
    aliases: ['makrut lime'],
  ),
  Ingredient(
    id: 'bergamot',
    name: 'Bergamot',
    imageUrl: 'assets/images/ingredients/bergamot.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'yuzu',
    name: 'Yuzu',
    imageUrl: 'assets/images/ingredients/yuzu.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'buddha_hand',
    name: 'Buddha Hand',
    imageUrl: 'assets/images/ingredients/buddha_hand.webp',
    aliases: ['buddha hand citron'],
  ),
  Ingredient(
    id: 'kumquat',
    name: 'Kumquat',
    imageUrl: 'assets/images/ingredients/kumquat.webp',
    aliases: ['kumquats'],
  ),
  Ingredient(
    id: 'calamondin',
    name: 'Calamondin',
    imageUrl: 'assets/images/ingredients/calamondin.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'pomelo',
    name: 'Pomelo',
    imageUrl: 'assets/images/ingredients/pomelo.webp',
    aliases: ['pomelos', 'pummelo'],
  ),
  Ingredient(
    id: 'tangerine',
    name: 'Tangerine',
    imageUrl: 'assets/images/ingredients/tangerine.webp',
    aliases: ['tangerines', 'mandarin', 'mandarins'],
  ),
  Ingredient(
    id: 'clementine',
    name: 'Clementine',
    imageUrl: 'assets/images/ingredients/clementine.webp',
    aliases: ['clementines'],
  ),
  Ingredient(
    id: 'satsuma',
    name: 'Satsuma',
    imageUrl: 'assets/images/ingredients/satsuma.webp',
    aliases: ['satsumas'],
  ),
  Ingredient(
    id: 'blood_orange',
    name: 'Blood Orange',
    imageUrl: 'assets/images/ingredients/blood_orange.webp',
    aliases: ['blood oranges'],
  ),
  Ingredient(
    id: 'seville_orange',
    name: 'Seville Orange',
    imageUrl: 'assets/images/ingredients/seville_orange.webp',
    aliases: ['bitter orange', 'bitter oranges'],
  ),
  
  // Grains and cereals
  Ingredient(
    id: 'barley',
    name: 'Barley',
    imageUrl: 'assets/images/ingredients/barley.webp',
    aliases: ['pearl barley'],
  ),
  Ingredient(
    id: 'wheat',
    name: 'Wheat',
    imageUrl: 'assets/images/ingredients/wheat.webp',
    aliases: ['wheat berries'],
  ),
  Ingredient(
    id: 'rye',
    name: 'Rye',
    imageUrl: 'assets/images/ingredients/rye.webp',
    aliases: ['rye berries'],
  ),
  Ingredient(
    id: 'millet',
    name: 'Millet',
    imageUrl: 'assets/images/ingredients/millet.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'sorghum',
    name: 'Sorghum',
    imageUrl: 'assets/images/ingredients/sorghum.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'buckwheat',
    name: 'Buckwheat',
    imageUrl: 'assets/images/ingredients/buckwheat.webp',
    aliases: ['kasha'],
  ),
  Ingredient(
    id: 'amaranth',
    name: 'Amaranth',
    imageUrl: 'assets/images/ingredients/amaranth.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'teff',
    name: 'Teff',
    imageUrl: 'assets/images/ingredients/teff.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'farro',
    name: 'Farro',
    imageUrl: 'assets/images/ingredients/farro.webp',
    aliases: ['emmer wheat'],
  ),
  Ingredient(
    id: 'spelt',
    name: 'Spelt',
    imageUrl: 'assets/images/ingredients/spelt.webp',
    aliases: ['dinkel'],
  ),
  Ingredient(
    id: 'bulgur',
    name: 'Bulgur',
    imageUrl: 'assets/images/ingredients/bulgur.webp',
    aliases: ['bulgur wheat'],
  ),
  Ingredient(
    id: 'couscous',
    name: 'Couscous',
    imageUrl: 'assets/images/ingredients/couscous.webp',
    aliases: [],
  ),
  Ingredient(
    id: 'polenta',
    name: 'Polenta',
    imageUrl: 'assets/images/ingredients/polenta.webp',
    aliases: ['cornmeal'],
  ),
  Ingredient(
    id: 'grits',
    name: 'Grits',
    imageUrl: 'assets/images/ingredients/grits.webp',
    aliases: ['hominy grits'],
  ),
  Ingredient(
    id: 'wild_rice',
    name: 'Wild Rice',
    imageUrl: 'assets/images/ingredients/wild_rice.webp',
    aliases: ['wild rice blend'],
  ),
  Ingredient(
    id: 'brown_rice',
    name: 'Brown Rice',
    imageUrl: 'assets/images/ingredients/brown_rice.webp',
    aliases: ['whole grain rice'],
  ),
  Ingredient(
    id: 'basmati_rice',
    name: 'Basmati Rice',
    imageUrl: 'assets/images/ingredients/basmati_rice.webp',
    aliases: ['basmati'],
  ),
  Ingredient(
    id: 'jasmine_rice',
    name: 'Jasmine Rice',
    imageUrl: 'assets/images/ingredients/jasmine_rice.webp',
    aliases: ['jasmine'],
  ),
  Ingredient(
    id: 'arborio_rice',
    name: 'Arborio Rice',
    imageUrl: 'assets/images/ingredients/arborio_rice.webp',
    aliases: ['arborio', 'risotto rice'],
  ),
  Ingredient(
    id: 'sushi_rice',
    name: 'Sushi Rice',
    imageUrl: 'assets/images/ingredients/sushi_rice.webp',
    aliases: ['short grain rice'],
  ),
  
  // Nuts and seeds
  Ingredient(
    id: 'almond',
    name: 'Almond',
    imageUrl: 'assets/images/ingredients/almond.webp',
    aliases: ['almonds'],
  ),
  Ingredient(
    id: 'walnut',
    name: 'Walnut',
    imageUrl: 'assets/images/ingredients/walnut.webp',
    aliases: ['walnuts'],
  ),
  Ingredient(
    id: 'pecan',
    name: 'Pecan',
    imageUrl: 'assets/images/ingredients/pecan.webp',
    aliases: ['pecans'],
  ),
  Ingredient(
    id: 'cashew',
    name: 'Cashew',
    imageUrl: 'assets/images/ingredients/cashew.webp',
    aliases: ['cashews'],
  ),
  Ingredient(
    id: 'pistachio',
    name: 'Pistachio',
    imageUrl: 'assets/images/ingredients/pistachio.webp',
    aliases: ['pistachios'],
  ),
  Ingredient(
    id: 'hazelnut',
    name: 'Hazelnut',
    imageUrl: 'assets/images/ingredients/hazelnut.webp',
    aliases: ['hazelnuts', 'filbert', 'filberts'],
  ),
  Ingredient(
    id: 'macadamia',
    name: 'Macadamia',
    imageUrl: 'assets/images/ingredients/macadamia.webp',
    aliases: ['macadamia nuts', 'macadamias'],
  ),
  Ingredient(
    id: 'brazil_nut',
    name: 'Brazil Nut',
    imageUrl: 'assets/images/ingredients/brazil_nut.webp',
    aliases: ['brazil nuts'],
  ),
  Ingredient(
    id: 'pine_nut',
    name: 'Pine Nut',
    imageUrl: 'assets/images/ingredients/pine_nut.webp',
    aliases: ['pine nuts', 'pignoli', 'pignolia'],
  ),
  Ingredient(
    id: 'chestnut',
    name: 'Chestnut',
    imageUrl: 'assets/images/ingredients/chestnut.webp',
    aliases: ['chestnuts'],
  ),
  Ingredient(
    id: 'sunflower_seed',
    name: 'Sunflower Seeds',
    imageUrl: 'assets/images/ingredients/sunflower_seed.webp',
    aliases: ['sunflower seed'],
  ),
  Ingredient(
    id: 'pumpkin_seed',
    name: 'Pumpkin Seeds',
    imageUrl: 'assets/images/ingredients/pumpkin_seed.webp',
    aliases: ['pumpkin seed', 'pepitas'],
  ),
  Ingredient(
    id: 'sesame_seed',
    name: 'Sesame Seeds',
    imageUrl: 'assets/images/ingredients/sesame_seed.webp',
    aliases: ['sesame seed'],
  ),
  Ingredient(
    id: 'chia_seed',
    name: 'Chia Seeds',
    imageUrl: 'assets/images/ingredients/chia_seed.webp',
    aliases: ['chia seed'],
  ),
  Ingredient(
    id: 'flax_seed',
    name: 'Flax Seeds',
    imageUrl: 'assets/images/ingredients/flax_seed.webp',
    aliases: ['flax seed', 'linseed', 'linseeds'],
  ),
  Ingredient(
    id: 'hemp_seed',
    name: 'Hemp Seeds',
    imageUrl: 'assets/images/ingredients/hemp_seed.webp',
    aliases: ['hemp seed', 'hemp hearts'],
  ),
  Ingredient(
    id: 'poppy_seed',
    name: 'Poppy Seeds',
    imageUrl: 'assets/images/ingredients/poppy_seed.webp',
    aliases: ['poppy seed'],
  ),
  Ingredient(
    id: 'quinoa_seed',
    name: 'Quinoa Seeds',
    imageUrl: 'assets/images/ingredients/quinoa_seed.webp',
    aliases: ['quinoa seed'],
  ),
  
  // More legumes
  Ingredient(
    id: 'black_bean',
    name: 'Black Beans',
    imageUrl: 'assets/images/ingredients/black_bean.webp',
    aliases: ['black bean'],
  ),
  Ingredient(
    id: 'kidney_bean',
    name: 'Kidney Beans',
    imageUrl: 'assets/images/ingredients/kidney_bean.webp',
    aliases: ['kidney bean'],
  ),
  Ingredient(
    id: 'pinto_bean',
    name: 'Pinto Beans',
    imageUrl: 'assets/images/ingredients/pinto_bean.webp',
    aliases: ['pinto bean'],
  ),
  Ingredient(
    id: 'navy_bean',
    name: 'Navy Beans',
    imageUrl: 'assets/images/ingredients/navy_bean.webp',
    aliases: ['navy bean', 'haricot bean', 'haricot beans'],
  ),
  Ingredient(
    id: 'cannellini_bean',
    name: 'Cannellini Beans',
    imageUrl: 'assets/images/ingredients/cannellini_bean.webp',
    aliases: ['cannellini bean', 'white kidney bean', 'white kidney beans'],
  ),
  Ingredient(
    id: 'adzuki_bean',
    name: 'Adzuki Beans',
    imageUrl: 'assets/images/ingredients/adzuki_bean.webp',
    aliases: ['adzuki bean', 'azuki bean', 'azuki beans'],
  ),
  Ingredient(
    id: 'mung_bean',
    name: 'Mung Beans',
    imageUrl: 'assets/images/ingredients/mung_bean.webp',
    aliases: ['mung bean', 'moong bean', 'moong beans'],
  ),
  Ingredient(
    id: 'fava_bean',
    name: 'Fava Beans',
    imageUrl: 'assets/images/ingredients/fava_bean.webp',
    aliases: ['fava bean', 'broad bean', 'broad beans'],
  ),
  Ingredient(
    id: 'lima_bean',
    name: 'Lima Beans',
    imageUrl: 'assets/images/ingredients/lima_bean.webp',
    aliases: ['lima bean', 'butter bean', 'butter beans'],
  ),
  Ingredient(
    id: 'split_pea',
    name: 'Split Peas',
    imageUrl: 'assets/images/ingredients/split_pea.webp',
    aliases: ['split pea'],
  ),
  Ingredient(
    id: 'black_eyed_pea',
    name: 'Black-Eyed Peas',
    imageUrl: 'assets/images/ingredients/black_eyed_pea.webp',
    aliases: ['black eyed pea', 'cowpea', 'cowpeas'],
  ),
];
