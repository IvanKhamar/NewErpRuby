# Sort key in Ukrainian alphabetical order (є, і, ї, ґ in their places), ignoring case, like .NET's uk-UA culture.
# Ruby's default String#<=> sorts by code points, which puts "і" and "є" after "я".
module UkrainianSort
  ALPHABET = "абвгґдеєжзиіїйклмнопрстуфхцчшщьюя".chars.each_with_index.to_h.freeze

  module_function

  # Spaces, digits and Latin letters come before Cyrillic, as in .NET.
  def key(text)
    text.to_s.downcase.chars.map { |c| ALPHABET.key?(c) ? [1, ALPHABET[c]] : [0, c.ord] }
  end
end
