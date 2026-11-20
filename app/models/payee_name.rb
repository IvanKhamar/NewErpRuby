# Comparing the name a customer gave with the holder of the account, like the UK's Confirmation of Payee:
# "Олена Коваленко", "КОВАЛЕНКО ОЛЕНА ПЕТРІВНА" and "Olena Kovalenko" are the same person; "Олена Коваленкo" with a
# typo is close; "Ігор Шевчук" is not.
#
# Normalization: lower case, every kind of apostrophe and quote removed (', ʼ, ’, `, «»), hyphens and dots become
# spaces, legal form words (ФОП, ТОВ) dropped, Cyrillic transliterated to Latin by the Ukrainian national system
# (the Cabinet of Ministers' table of 2010, the one in passports). Word order does not matter.
class PayeeName
  MATCH = "match".freeze
  CLOSE_MATCH = "close_match".freeze
  NO_MATCH = "no_match".freeze

  CLOSE = 0.8 # a word this similar (1 − edits / length) still counts as the same word with a typo

  LEGAL_FORMS = %w[fop tov pp prat at vat fizychna osoba].freeze
  APOSTROPHES = /['ʼ’‘`´"«»„“”]/

  # Letters at the start of a word are written differently (Є → Ye, but ...є → ie).
  START = { "є" => "ye", "ї" => "yi", "й" => "y", "ю" => "yu", "я" => "ya" }.freeze
  LETTERS = {
    "а" => "a", "б" => "b", "в" => "v", "г" => "h", "ґ" => "g", "д" => "d", "е" => "e", "є" => "ie", "ж" => "zh",
    "з" => "z", "и" => "y", "і" => "i", "ї" => "i", "й" => "i", "к" => "k", "л" => "l", "м" => "m", "н" => "n",
    "о" => "o", "п" => "p", "р" => "r", "с" => "s", "т" => "t", "у" => "u", "ф" => "f", "х" => "kh", "ц" => "ts",
    "ч" => "ch", "ш" => "sh", "щ" => "shch", "ь" => "", "ю" => "iu", "я" => "ia",
    # Russian letters people still type
    "ы" => "y", "э" => "e", "ё" => "io", "ъ" => ""
  }.freeze

  Result = Data.define(:result, :score)

  def self.words(name)
    name.to_s.downcase.gsub(APOSTROPHES, "").gsub(%r{[-.,_/]}, " ").split
        .map { |word| transliterate(word) }.reject { |word| word.empty? || LEGAL_FORMS.include?(word) }
  end

  def self.transliterate(word)
    word = word.gsub("зг", "zgh") # so "Згурський" is not read as "Zhurskyi"
    first = word[0]
    rest = word[1..].to_s
    (START[first] || LETTERS.fetch(first, first)) + rest.chars.map { |c| LETTERS.fetch(c, c) }.join
  end

  # 1 − Levenshtein distance / the longer length: 1.0 the same, 0.0 nothing in common.
  def self.similarity(left, right)
    return 1.0 if left == right

    previous = (0..right.length).to_a
    left.each_char.with_index(1) do |char, i|
      current = [i]
      right.each_char.with_index(1) do |other, j|
        current << [previous[j] + 1, current[j - 1] + 1, previous[j - 1] + (char == other ? 0 : 1)].min
      end
      previous = current
    end
    1.0 - (previous.last.to_f / [left.length, right.length].max)
  end

  def self.compare(entered, holder)
    given = words(entered)
    known = words(holder)
    return Result.new(result: NO_MATCH, score: 0.0) if given.empty? || known.empty?
    return Result.new(result: MATCH, score: 1.0) if given.sort == known.sort

    # Each word the customer gave against its best counterpart in the holder's name.
    scores = given.map { |word| known.map { |k| similarity(word, k) }.max }
    score = (scores.sum / [given.size, known.size].max).round(3)
    # Close: every given word is (almost) in the holder's name, and at least the first and last name are there,
    # so a missing patronymic or one typo still counts; one shared surname does not.
    close = scores.all? { |s| s >= CLOSE } && given.size >= [2, known.size].min
    Result.new(result: close ? CLOSE_MATCH : NO_MATCH, score:)
  end
end
