class ConvertCostValueToDecimal < ActiveRecord::Migration[6.1]
  # DReSA fork patch (2026-09-25): the original checked the column type via
  # the Event MODEL (Event.type_for_attribute), but the current model declares
  # an enum on the "presence" column, which does not exist until the Aug 2023
  # migration - so loading the model here raises under Rails 7.1+. Checking
  # the column via the database connection avoids loading the model entirely.
  def up
    cost_type = connection.columns(:events).find { |c| c.name == "cost_value" }&.sql_type.to_s
    unless cost_type.start_with?("numeric", "decimal")
      change_column :events, :cost_value, :decimal, using:
        "CASE WHEN (cost_value <> '') IS NOT TRUE THEN NULL ELSE CAST(cost_value AS DECIMAL) END"
    end
  end

  def down
    change_column :events, :cost_value, :text
  end
end
