<logger>
	<div class="widget__head">События</div>

	<div class="flex-block flex_rows flex__item">
		<div class="logger flex__item" name="loggerwheel" onmousewheel="{mousewheel}" onscroll="{scroll}">
			<div class="row row-new" >

				<div class="col-sm-2 logger__item" each={item, i in data} >
					<div class="logger__date">{moment(item.timestamp).format("hh:mm")}</div>
					<div class="logger__title">{item.author}</div>
					<div class="logger__desc">{item.message}</div>
				</div>

			</div>
		</div>
	</div>


	<script>
		this.mixin('riotControl')

        var control = this.riotControl()

		this.data = []

		this.params = {
			name : opts.name || null,
			id	 : opts.id || null,
			query: opts.query || {},
	        sort : {
				field: "timestamp",
				type: "desc"
			},
			paging: "true",
			_key: null
	    }

	    this.on('mount', () => {
			RiotControl.trigger("init", clone(this.params))
		})

	    this.mousewheel = e => {
	    	e.preventUpdate = true

	    	if (e.deltaY > 0)
	    		this.loggerwheel.scrollLeft += 200;
	    	else
	    		this.loggerwheel.scrollLeft -= 200;

	    	this.checkScrollEnd()
	    }

	    this.scroll = e => {
	    	e.preventUpdate = true
	    	this.checkScrollEnd()
	    }

	    this.checkScrollEnd = () => {
	    	if (this.loggerwheel.scrollWidth - this.loggerwheel.scrollLeft == this.loggerwheel.clientWidth) {
	    		RiotControl.trigger("newpage", clone(this.params))
	    	}
	    }

		control.ON("loadcomplete_" + opts.name, logs => {
			if(!jSonCmpWithNewObject(logs.params, this.params)) return
			
			this.data = logs.data

			this.params._key = logs.params._key
			
			this.update()
		})

		control.ON("loadpage_" + opts.name, logs => {
			if(!jSonCmpWithNewObject(logs.params, this.params)) return

			this.data = this.data.concat(logs.data)
            this.update()
		})

		this.one('unmount', () => {
			control.OFF()
		})
	</script>
</logger>