/* glop.js
 *
 * Copyright (C) 2009 Design Ecology, MIT Media Lab
 *
 * This file is part of the Loom project. Read more at
 * <http://eco.media.mit.edu>
 *
 */
 
/* The following sections (until "BEGIN LOOM") are not part of Loom. 
 */

/* **** BEGIN PROTOTYPE **** */

//= require <../lib/prototype>

/* **** END PROTOTYPE **** */

/* **** BEGIN LOOM **** */

var Environment = {
	canvas_id: 'canvas',
	canvas: function() {
		return document.getElementById(this.canvas_id)
	},
	observe: function(e,task) {
		Environment.canvas().observe(e, task)
	},
	/**
	 * Called from Loom.setup(), actually boots up the environment.
	 */
	initialize: function(configs) {
		if (configs) {
			if (configs['width']) this.canvas().width = configs['width']
			if (configs['height']) this.canvas().height = configs['height']
			if (configs['height'] || configs['width']) configs['resizable'] = false
		}
		Config.initialize(configs)
		$C.init()
		document.fire('environment:init')
		
		Glop.trigger_draw()
	},
	/**
	 * Called from index.html, triggers environment boot-up on DOM load.
	 */
	setup: function(configs) {
		$(document).observe('dom:loaded', function() {
			Environment.initialize(configs)
		})	
	},
	draw: function() {

	}
	
}

/* **** END LOOM **** */

//= require <util/util>
//= require <config/config>
//= require <glop/glop>
//= require <interface/interface>
