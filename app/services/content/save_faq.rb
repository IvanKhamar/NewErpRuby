module Content
  # Creates or changes an FAQ entry. The answer is HTML from an editor, so it is cleaned (HtmlContent) before saving.
  class SaveFaq < ApplicationService
    Form = Data.define(:question, :answer, :author, :email, :sort_order, :enabled)

    def initialize(faq_id:, form:)
      @faq_id = faq_id
      @form = form
    end

    def call
      faq = @faq_id ? Faq.find_by(faq_id: @faq_id) : Faq.new(date_added: Time.current.change(usec: 0))
      return not_found("Запису #{@faq_id} немає.") if faq.nil?

      question = @form.question.to_s.strip
      return failure("Вкажіть питання.") if question.empty?

      email = @form.email.to_s.strip
      return failure("E-mail «#{email}» записано з помилкою.") if email.present? && !email.match?(Faq::EMAIL)

      save(faq, question, email)
      success(faq.reload)
    end

    private

    # dd_faq and its description are MyISAM: two plain writes, the entry first (to get its id).
    def save(faq, question, email)
      faq.update!(author: @form.author.to_s.strip, email:, sort_order: @form.sort_order.to_i,
                  status: @form.enabled.nil? || @form.enabled)
      description = FaqDescription.find_or_initialize_by(faq_id: faq.id, language_id: ErpSettings.language_id)
      description.update!(name: question, description: HtmlContent.clean(@form.answer))
    end
  end
end
