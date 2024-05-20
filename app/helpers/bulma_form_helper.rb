# frozen_string_literal: true

# Wrap rails form builder fields in Buma structure and render valiation errors
module BulmaFormHelper
  def bulma_field(form, type, record, field_name, **kwargs, &)
    label = kwargs.delete(:label)
    label = " #{label}" if label && type == :check_box
    css_classes = kwargs.delete(:class)&.split || []
    css_classes << 'input' unless type == :check_box
    error = nil
    if !record.valid? && record.errors[field_name].present?
      error = record.errors.full_messages_for(field_name).join(', ')
      css_classes << 'is-danger'
    end

    field_args = { **kwargs, class: css_classes.join(' ') }

    render('form_field',
           f: form, type: type, field_name: field_name, label: label, error: error, field_args: field_args, &)
  end
end
