module Api
  module V1
    # The storefront's FAQ (Admin, Manager). Answers are cleaned HTML.
    class FaqController < BaseController
      before_action -> { authorize :orders, :manage? }

      def index
        render json: Faq.includes(:description).sorted.map { |faq| faq_json(faq) }
      end

      def create = save(nil, :created)
      def update = save(params[:id].to_i, :ok)

      private

      def save(faq_id, status)
        p = params.permit(:question, :answer, :author, :email, :sortOrder, :enabled)
        form = Content::SaveFaq::Form.new(question: p[:question], answer: p[:answer], author: p[:author],
                                          email: p[:email], sort_order: p[:sortOrder], enabled: p[:enabled])
        result = Content::SaveFaq.call(faq_id:, form:)
        return render_failure(result) unless result.success?

        render json: faq_json(result.value), status:
      end

      def faq_json(faq)
        { id: faq.id, question: faq.description&.name.to_s, answer: faq.description&.description.to_s,
          author: faq.author.to_s, email: faq.email.to_s, sortOrder: faq.sort_order,
          enabled: faq.status ? true : false }
      end
    end
  end
end
