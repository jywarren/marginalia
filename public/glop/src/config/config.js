var Config = {
	powersave: false,
	/**
	 * Whether Glop tries to resize the canvas element every frame;
	 * if set to true, this also seems to clear the canvas every frame.
	 */
	resizeable: false,
	/**
	 * Array of files to load after Cartagen's initialization
	 * @deprecated
	 */
	dynamic_layers: [],
	fullscreen: false,
	debug: false,
	aliases: $H({
		stylesheet: ['gss']
	}),
	handlers: $H({
		debug: function(value) {
			$D.enable()
		},
		fullscreen: function(value) {
			if ($('brief')) $('brief').hide()
		},
	}),
	initialize: function(config) {
		// stores passed configs and query string configs in the Config object
		Object.extend(this, config)
		Object.extend(this, this.get_url_params())
		
		this.apply_aliases()
		
		this.run_handlers()
	},
	get_url_params: function() {
		return window.location.href.toQueryParams()
	},
	apply_aliases: function() {
		this.aliases.each(function(pair) {
			pair.value.each(function(value) {
				if (this[value]) this[pair.key] = this[value]
			}, this)
		}, this)
	},
	run_handlers: function() {
		this.handlers.each(Config.run_handler)
	},
	run_handler: function(handler) {
		if (Config[handler.key]) handler.value(Config[handler.key])
	}
}


