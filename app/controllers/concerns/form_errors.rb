# frozen_string_literal: true

# When submitting a form, if the operation fails, save the parameters in flash
# and restore on the form again. This allows displaying validation errors.
module FormErrors
  extend ActiveSupport::Concern

  def record_changes!(record)
    flash[:form_params] ||= {}
    flash[:form_params][record.class.name] =
      record.new_record? ? record.attributes : record.attributes.slice(*record.changed_attributes.keys)
  end

  def restore_changes!(record)
    record.assign_attributes(recoreded_changes(record.class.name))
  end

  def recoreded_changes(class_name)
    changes = flash[:form_params] || {}
    changes[class_name] || {}
  end
end
