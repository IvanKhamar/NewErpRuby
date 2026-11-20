require "rails_helper"

RSpec.describe PayeeName do
  def result(entered, holder) = described_class.compare(entered, holder).result

  describe ".words" do
    it "transliterates Ukrainian by the national table, with the start-of-word letters" do
      expect(described_class.words("Олена Коваленко")).to eq(%w[olena kovalenko])
      expect(described_class.words("Євген Юрченко")).to eq(%w[yevhen yurchenko])
      expect(described_class.words("Згурський Щербина")).to eq(%w[zghurskyi shcherbyna])
      expect(described_class.words("Їжакевич Ярослава")).to eq(%w[yizhakevych yaroslava])
    end

    it "ignores case, apostrophes of every kind, hyphens and legal forms" do
      expected = %w[mariana solovian]
      ["Мар'яна Солов'ян", "МАРʼЯНА СОЛОВʼЯН", "Мар’яна Солов`ян", "мар´яна соловʼян"].each do |name|
        expect(described_class.words(name)).to eq(expected), name
      end
      expect(described_class.words("ФОП Анна-Марія Коваль")).to eq(%w[anna mariia koval])
      expect(described_class.words("ТОВ «Квітка»")).to eq(%w[kvitka])
    end
  end

  describe ".compare" do
    it "matches the same person written in any order, case or alphabet" do
      expect(result("Олена Коваленко", "КОВАЛЕНКО ОЛЕНА")).to eq("match")
      expect(result("Olena Kovalenko", "Коваленко Олена")).to eq("match")
      expect(result("Мар'яна Соловʼян", "Соловʼян Марʼяна")).to eq("match")
      expect(result("Олена Коваленкo", "Коваленко Олена")).to eq("match") # a Latin "o" typed by mistake
    end

    it "calls a missing patronymic or one typo a close match" do
      expect(result("Олена Коваленко", "Коваленко Олена Петрівна")).to eq("close_match")
      expect(result("Олена Коваленка", "Коваленко Олена")).to eq("close_match") # one letter wrong
      expect(result("Olena Kovalenco", "Коваленко Олена")).to eq("close_match")
    end

    it "does not match another person, a shared surname alone or nothing" do
      expect(result("Ігор Шевчук", "Коваленко Олена")).to eq("no_match")
      expect(result("Коваленко", "Коваленко Олена Петрівна")).to eq("no_match")
      expect(result("Петро Коваленко", "Коваленко Олена")).to eq("no_match")
      expect(result("", "Коваленко Олена")).to eq("no_match")
    end
  end

  it "measures similarity as 1 − edits / length" do
    expect(described_class.similarity("kovalenko", "kovalenko")).to eq(1.0)
    expect(described_class.similarity("kovalenko", "kovalenco")).to be_within(0.001).of(1 - (1.0 / 9))
    expect(described_class.similarity("abc", "xyz")).to eq(0.0)
  end
end
