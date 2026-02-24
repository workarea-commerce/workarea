# WA-NEW-010: Silence the BSON Symbol deprecation warning emitted when
# mongoid-audit_log defines `field :action, type: Symbol` in Entry.
#
# Background: Mongoid::Fields::Validators::Macro fires a one-time warning
# ("The BSON symbol type is deprecated; use String instead") the first time it
# encounters a field with type: Symbol. The mongoid-audit_log gem still uses
# Symbol for its :action field; we cannot change the gem, but we *do* override
# the field to type: String in our decorator (see ext/mongoid/audit_log_entry.rb).
#
# To avoid the spurious warning from the gem's own definition, we pre-set the
# Mongoid one-time-warned flag here — before mongoid/audit_log is required —
# since the real fix (using String) is applied in our decorator immediately
# after. The suppression is therefore safe and correctly scoped.
if defined?(Mongoid::Fields::Validators::Macro)
  Mongoid::Fields::Validators::Macro.instance_variable_set(
    :@field_type_is_symbol_warned,
    true
  )
end
