module Admin
  # Production models and the cut / to-sewing / sewn / ship operations (Admin, Storekeeper).
  class ProductionModelsController < BaseController
    before_action -> { authorize :production, :manage? }

    def index
      @models = ProductionModel.active.includes(:sizes).sorted
    end

    def show
      @model = ProductionModel.active.includes(:sizes, { components: { bom_lines: :item } }).find(params.expect(:id))
    end

    # One form row per size: the quantities that are filled in are recorded in one operation.
    def operations
      rows = []
      params.fetch(:quantities, {}).each_pair do |size_id, quantity|
        next if quantity.blank?

        rows << Production::RecordOperation::Row.new(size_id: size_id.to_i,
                                                     quantity: BigDecimal(quantity.to_s.tr(",", ".")))
      end
      result = Production::RecordOperation.call(production_id: params[:id].to_i, operation: params[:operation],
                                                rows:, comment: params[:comment], warehouse_id: nil,
                                                user: Current.user)
      flash_result(result, notice: "Записано.")
      redirect_to admin_production_model_path(params[:id]), status: :see_other
    rescue ArgumentError
      redirect_to admin_production_model_path(params[:id]), alert: "Кількість має бути числом.", status: :see_other
    end
  end
end
