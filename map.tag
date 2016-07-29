<map>
	<div name='maptag' class="map"></div>

	<script>
		var self = this

		this.on('mount', () => {

			this.map = L.map(this.maptag, {
				center: [43.026305, 44.677170],
				zoom: 13,
				fadeAnimation: true,
				zoomAnimation: true
			});

			var osm = L.tileLayer( 'http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
			    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
		    }),
			googleLayer = new L.Google('ROADMAP'),
			yndx = new L.Yandex()

			this.map.addLayer(osm)
			this.map.addControl(new L.Control.Layers({
				'OSM':osm, 
				"Yandex":yndx, 
				"Google":googleLayer
			}));

			if (this.opts.mixin) {
				this.opts.mixin.map = this.map
				this.opts.mixin.ondraw && this.opts.mixin.ondraw()
			}
		})

		this.on('update', () => {
			setTimeout(() => {
				this.map && this.map.invalidateSize()
			}, 50)
		})
	
	</script>
	<style scope>
		.map {
			width: 100%;
			height: 100%;
			position: absolute;
		}
	</style>
</map>
