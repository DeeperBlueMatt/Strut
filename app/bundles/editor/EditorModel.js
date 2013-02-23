define(['libs/backbone',
		'bundles/header/model/HeaderModel',
		'bundles/presentation_generator/model/PresentationGeneratorCollection',
		'bundles/deck/Deck',
		'bundles/slide_components/ComponentFactory'],
function(Backbone, Header, PresentationGeneratorCollection, Deck, ComponentFactory) {
	return Backbone.Model.extend({
		initialize: function() {
			this._loadLastPresentation();

			this.set('presentationGenerators', 
				new PresentationGeneratorCollection(this));
			this.set('header', new Header(this.registry, this));

			this.set('modeId', 'slide-editor');
			this._createMode();
		},

		changeActiveMode: function(modeId) {
			if (modeId != this.get('modeId')) {
				this.set('modeId', modeId);
				this._createMode();
			}
		},

		deck: function() {
			return this._deck;
		},

		addSlide: function(index) {
			this._deck.newSlide(index);
		},

		addComponent: function(type) {
			var slide = this._deck.get('activeSlide');
			if (slide) {
				var comp = ComponentFactory.instance.createModel(type);
				slide.add(comp);
			}
		},

		_createMode: function() {
			var modeId = this.get('modeId');
			var modeService = this.registry.getBest({
				interfaces: 'strut.EditMode',
				meta: { id: modeId }
			});

			if (modeService) {
				var prevMode = this.get('activeMode');
				if (prevMode)
					prevMode.close();
				this.set('activeMode', modeService.getMode(this, this.registry));
			}
		},

		_loadLastPresentation: function() {
			// Look in localStorage for a preferred provider
			// and access information

			// attempt connection to prefferd provider
			this._deck = new Deck();
			this.addSlide();
		},

		_loadGenerators: function() {
			
		},

		constructor: function EditorModel(registry) {
			this.registry = registry;
			Backbone.Model.prototype.constructor.call(this);
		}
	});
});