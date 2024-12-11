# frozen_string_literal: true

# When submitting a form, if the operation fails, save the parameters in flash
# and restore on the form again. This allows displaying validation errors.
module FormErrors
  extend ActiveSupport::Concern

  def record_changes!(record)
    flash[:form_params] ||= {}
    if record.is_a?(Array)
      return if record.empty?

      flash[:form_params][record.first.class.name] = record.map do |element|
        element.new_record? ? element.attributes : element.attributes.slice(*element.changed_attributes.keys)
      end
    else
      flash[:form_params][record.class.name] =
        record.new_record? ? record.attributes : record.attributes.slice(*record.changed_attributes.keys)
    end
  end

  def restore_changes!(record)
    if record.is_a?(Array)
      return if record.empty?
      return unless flash.to_h.dig(:form_params, record.first.class.name)

      flash[:form_params][record.first.class.name].each_with_index do |element, index|
        record[index] = record.first.class.new
        record[index].assign_attributes(element)
      end
    else
      record.assign_attributes(recoreded_changes(record.class.name))
    end
  end

  def recoreded_changes(class_name)
    changes = flash[:form_params] || {}
    changes[class_name] || {}
  end
end
