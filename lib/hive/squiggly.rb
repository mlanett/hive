# -*- encoding: utf-8 -*-

module Squiggly

  ADJECTIVES = ["able", "afraid", "bad", "bitter", "brave", "bright", "busy", "careful", "cheap", "clean", "clear", "clever", "close", "cloudy", "cold", "comfortable", "cool", "cute", "dangerous", "dapper", "dark", "dead", "deep", "difficult", "dirty", "dry", "early", "empty", "exciting", "expensive", "fair", "famous", "far", "fast", "fat", "fine", "flat", "free", "free", "free", "fresh", "full", "funny", "good", "great", "happy", "hard", "healthy", "heavy", "high", "hungry", "important", "interesting", "kind", "large", "late", "lazy", "light", "long", "loud", "low", "lucky", "narrow", "near", "noisy", "old", "polite", "proud", "quick", "quiet", "rich", "sad", "safe", "salty", "scared", "short", "slimey", "slow", "small", "soft", "sour", "strong", "strong", "sweet", "thick", "thirsty", "tidy", "useful", "warm", "weak", "weak", "whole", "windy"]
  ANIMALS    = ["aardvarks", "ants", "badgers", "bats", "bears", "bees", "butterflies", "canaries", "cattle", "chickens", "chihuahuas", "clams", "cockles", "crabs", "crows", "deer", "dogs", "donkeys", "doves", "dragonflies", "ducks", "ferrets", "flies", "foxes", "frogs", "geese", "gerbils", "goats", "guinea pigs", "hamsters", "hares", "hawks", "hedgehogs", "herons", "horses", "hummingbirds", "kingfishers", "lobsters", "mice", "moles", "moths", "mussles", "newts", "otters", "owls", "oysters", "parrots", "peafowl", "pheasants", "pigeons", "pigs", "pikes", "platypuses", "rabbits", "rats", "robins", "rooks", "salmons", "sheep", "snails", "snakes", "sparrows", "spiders", "squid", "squirrels", "starlings", "stoats", "swans", "toads", "trouts", "wasps", "weasels"]
  VERBS      = ["cried", "cuddled", "danced", "drove", "engaged", "felt", "floundered", "fought", "hid", "hopped", "hugged", "jumped", "kissed", "knitted", "listened", "loitered", "married", "played", "played", "ran", "sang", "sat", "snuggled", "talked", "walked", "went", "whimpered", "whimpered", "whispered"]
  ADVERBS    = ["cordially", "easily", "jovially", "merrily", "quickly"]

  def sentence
    count = rand(8) + 2
    [ count, ADJECTIVES.sample, ANIMALS.sample, VERBS.sample, ADVERBS.sample ].join(" ")
  end

  def subject
    [ ADJECTIVES.sample, ANIMALS.sample ].join(" ")
  end

  extend Squiggly
end # Squiggly
