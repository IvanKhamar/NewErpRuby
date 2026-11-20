module Orders
  # Reactions of other modules to an order status change (IOrderStatusHandler in the .NET version).
  # Each handler is an object with `call(change)` that returns a list of warnings for the person.
  # To react to statuses in a new way, add a handler here; Orders::ChangeStatus does not change.
  module StatusHandlers
    module_function

    def all = [SewnStock.new]
  end
end
