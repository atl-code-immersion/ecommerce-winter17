class CartController < ApplicationController

	before_filter :authenticate_user!, except: [:add_to_cart, :view_order]

  def add_to_cart
  	line_item = LineItem.create(product_id: params[:product_id], quantity: params[:quantity])

  	line_item.update(line_item_total: (line_item.product.price * line_item.quantity))

  	redirect_to :back
  end

  def view_order
  	@line_items = LineItem.all
  	@sum = 0
  	LineItem.pluck(:line_item_total).each do |num|
  		@sum += num
  	end
  end

  def checkout
  	line_items = LineItem.all
  	@order = Order.create(user_id: current_user.id, subtotal: 0)

  	line_items.each do |line_item|
  		line_item.product.update(quantity: (line_item.product.quantity - line_item.quantity))
  		@order.order_items[line_item.product_id] = line_item.quantity 
  		@order.subtotal += line_item.line_item_total
  	end
		@order.save

  	@order.update(sales_tax: (@order.subtotal * 0.08))
  	@order.update(grand_total: (@order.sales_tax + @order.subtotal))

  	line_items.destroy_all
  end
end





