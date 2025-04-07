# services/loyalty_service.rb
require_relative '../models/user'
require_relative '../models/template'
require_relative '../models/product'
require_relative '../models/operation'

class ::LoyaltyService
  # 1) Метод расчёта
  def self.calculate_operation(user_id, positions)
    user = ::User[user_id]
    template = user.template
    
    # в https://api.teyca.ru/ ошибки выходят текстом
    return text_error(404, 'Клиент не найден!') unless user
    return text_error(404,'Template not found' ) unless template
  
    base_discount  = template.discount
    base_cashback  = template.cashback
  
    total_price       = 0.0
    total_discount    = 0.0
    total_cashback    = 0.0
    noloyalty_amount  = 0.0
    positions_result  = []
  
    positions.each do |pos|
      product_id = pos[:id]
      price      = pos[:price].to_f
      quantity   = pos[:quantity].to_f
  
      sum_for_items = price * quantity
      total_price  += sum_for_items
  
      product       = ::Product[product_id]
      product_type  = product&.type
      product_value = product&.value
  
      discount_percent = base_discount
      cashback_percent = base_cashback
      type_desc        = nil
  
      case product_type
      when 'discount'
        discount_percent += product_value.to_i
        type_desc = "Дополнительная скидка #{product_value}%"
      when 'increased_cashback'
        cashback_percent += product_value.to_i
        type_desc = "Дополнительный кэшбэк #{product_value}%"
      when 'noloyalty'
        discount_percent = 0
        cashback_percent = 0
        type_desc = "Не участвует в системе лояльности"
        noloyalty_amount += sum_for_items
      end
  
      item_discount = (sum_for_items * discount_percent / 100.0)
      item_sum_after_discount = sum_for_items - item_discount
      item_cashback = (item_sum_after_discount * cashback_percent / 100.0)
  
      total_discount += item_discount
      total_cashback += item_cashback
  
      positions_result << {
        id: product_id,
        price: price,
        quantity: quantity,
        type: product_type,
        value: product_value,
        type_desc: type_desc,
        discount_percent: discount_percent.to_f.round(1),
        discount_summ: item_discount.round(2)
      }
    end
  
    final_sum = total_price - total_discount
  
    overall_discount_percent = total_price.zero? ? 0.0 : (total_discount / total_price * 100.0).round(2)
    overall_cashback_percent = total_price.zero? ? 0.0 : (total_cashback / total_price * 100.0).round(2)
  
    allowed_write_off = final_sum - noloyalty_amount
    allowed_write_off = 0 if allowed_write_off < 0
  
    will_add = total_cashback.floor
  
    cashback_percent_display = final_sum.zero? ? '0.00%' : format('%.2f%%', will_add / final_sum * 100.0)
  
    operation = ::Operation.create(
      user_id:           user.id,
      cashback:          total_cashback.round(2),
      cashback_percent:  overall_cashback_percent,
      discount:          total_discount.round(2),
      discount_percent:  overall_discount_percent,
      write_off:         0,
      check_summ:        final_sum.round(2),
      done:              false,
      allowed_write_off: allowed_write_off.round(2)
    )
  
    {
      status: 200,
      user: {
        id: user.id,
        template_id: user.template_id,
        name: user.name,
        bonus: format('%.1f', user.bonus.to_f)
      },
      operation_id: operation.id,
      summ: final_sum.round(2),
      positions: positions_result,
      discount: {
        summ: total_discount.round(2),
        value: "#{overall_discount_percent.round(2)}%"
      },
      cashback: {
        existed_summ: user.bonus.to_f.round(1),
        allowed_summ: allowed_write_off.round(2),
        value: cashback_percent_display,
        will_add: will_add
      }
    }
  end

  # 2) Метод подтверждения
  def self.confirm_operation(user_id, operation_id, write_off_amount)
    user      = User[user_id]
    operation = Operation[operation_id]
    
    # в https://api.teyca.ru/ ошибки выходят текстом
    return text_error(404, 'Клиент не найден!') unless user
    return text_error(404, 'Операция не найдена!') unless operation
    return text_error(400, 'Операция уже проведена!') if operation.done
  
    write_off_amount = write_off_amount.to_f
  
    max_can_write_off = operation.allowed_write_off.to_f
    write_off_amount = [write_off_amount, max_can_write_off, user.bonus].min
  
    final_pay = operation.check_summ.to_f - write_off_amount
  
    user.bonus = user.bonus - write_off_amount + operation.cashback
    user.save
  
    operation.update(
      write_off: write_off_amount.round(2),
      check_summ: final_pay.round(2),
      done: true
    )
  
    {
      status: 200,
      message: 'Данные успешно обработаны!',
      operation: {
        user_id: user.id,
        cashback: operation.cashback.to_f.round,
        cashback_percent: operation.cashback_percent.to_f.round(0), 
        discount: format('%.1f', operation.discount.to_f),          
        discount_percent: format('%.2f', operation.discount_percent.to_f),
        write_off: write_off_amount.round(2),
        check_summ: final_pay.round(0)
      }
    }
  end
  
  def self.text_error(status_code, message)
    throw :halt, [status_code, { 'Content-Type' => 'text/plain' }, message]
  end
  
end
