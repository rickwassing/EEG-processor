function app = UpdateProperty(app, Object, Property, Value)

if ~isequaln(Object.(Property), Value)
    Object.(Property) = Value;
end

end
