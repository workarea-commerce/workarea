module Workarea::GuardNegativePrice
  def guard_negative_price
    result = yield || 0.to_money
    0.to_money > result ? 0.to_money : result
  end
end
