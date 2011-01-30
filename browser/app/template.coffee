# Manages the App's templates
class Template
    
    # Render a template
    renderTemplate: (name, templateContext = {}) ->
        
        # Ugly way of getting around CoffeeKup's compilation-into-singular-template-function
        templateContext.template = name
        
        window.template context: templateContext