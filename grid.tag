<!--Шаблон ячейки-->
<cell class="grid__cell" onclick={cellclick} ondblclick={doubleClick} style="flex-basis: {parent.parent.settings[item]}" no-reorder>
	<div class="grid__cell-content">{render()}</div>

	<script>

		var p = this.parent,
		    pp = p.parent

		this.render = e => {
			if (pp.opts.mixin.render[this.item]) {
				return pp.opts.mixin.render[this.item](p.item[this.item], this.root, p.item)
			} 
			return  p.item[this.item]
		}

		doubleClick(e) {
			e.preventUpdate = true

			if ( this.hasOwnProperty("ondbclick")) {
				var obj = Object.assign(this.parent.item)
				delete obj.selected 
				this.ondbclick(obj)
			}
			
		}

		this.cellclick = e => {
			if (pp.selObj.selected) {
				pp.selObj[pp.selObj.selected.parent.item.id] = false
				pp.selObj.selected.parent.update()
			}

			pp.selObj = {}
			pp.selObj[this.parent.item.id] = true
			pp.selObj.selected = this

			if( this.hasOwnProperty("onclick") && e.detail == 1 ) {
				this.onclick(this.parent.item, this.item, this.i, this.j)
			}
		}
	</script>
</cell>


<!--Шаблон строки  item.selected "-->
<row class="grid__row { grid__row_selected: parent.selObj[item.id]}" style="width: { rowWidth }">
	<cell each={item, j in cellnames} no-reorder></cell>
</row>

<!--Шаблон заголовка-->
<gridhead class="grid__cell" style="flex-basis: {parent.settings[parent.cellnames[this.i]]}">
	<div class="grid__cell-title" onclick={sort} > { opts.value } </div>
	<div class="grid__cell-resize" onmousedown={parent.onmousedown}></div>
	
	<script>
		
	var parent = this.parent;

	this.sort = event => {
		if (parent.opts.localdata) return;

 		if ( parent.div ) parent.div.scrollTop = 0;

		var sort = parent.params.sort

		if ( sort.field && sort.field == parent.cellnames[event.item.i] ) {

			if ( sort.type == 'asc' ) {
				sort.type = 'desc'
			} else {
				sort.type  = null
				sort.field = null
			}
		} else {
			sort.field = parent.cellnames[event.item.i];
			sort.type  = 'asc';
		}
		parent.get()
	}
	</script>
</gridhead>

<grid onmouseup={onmouseup}>
	<div class="grid" id="table">
		<div class="grid__head">
			<div class="grid__row">
				<gridhead class="grid__cell" each={item, i in headnames} value={item} no-reorder></gridhead>
				<div class="grid__cell grid__cell_last"></div>
			</div>
		</div>

		<div class="grid__body" onscroll={onscroll}>
			<row class="grid__row" each={item, i in data} value={item} no-reorder></row>
		</div>
	</div>
	
	<script>

	this.mixin('riotControl')

    var control = this.riotControl()

	this.selObj = {}


	var self = this,
	    div,
	    scrollLeft = 0


	this.flag = true

	self.after = false
	self.selectedRow = ''
	self.pressed = false

	self.componentHash = HashCode({
		type: 'grid',
		name: opts.name || 'localdata',
		settings: opts.columns || CollectionColumn[opts.name || ''] || [],
		hash: location.hash 
	})
	
	if (!opts.mixin) opts.mixin = {} 
	if (!opts.mixin.render) opts.mixin.render = {}

	self.settings = {}
	self.headnames = []
	self.cellnames = []

	self.params = {
		name : opts.name || null,

		id	 : opts.id || null,
        query: opts.query || {},
        sort : {
			field: opts.sortfield || null,
			type: opts.sortftype || null
		},
		paging: opts.paging || false,
		_key: null
    }


	if ( opts.mixin ) {
		this.mixin(opts.mixin)
		opts.mixin.update = e => this.update()
		opts.mixin.updateData = () => this.get()

		opts.mixin.setQuery = e => {

			if ( e instanceof Array) {
				e.forEach(item => {
					if (typeof item.value == "object" ||  item.value.trim()) {
						if (item.name) {
							self.params.query[item.name] = item.value	
						}
					} else {
						delete self.params.query[item.name]
					}
				})
			} else {
				if (typeof e.value == "object" ||  e.value.trim()) {
					self.params.query[e.name] = e.value	
				} else {
					delete self.params.query[e.name]
				}
			}
			self.get()
		}

		opts.mixin.changeQuery = e => {
			self.params.query = e
			self.get()
		}


		opts.mixin.setData = data => {
			self.data = data;
			self.update();
		}

		opts.mixin.changeID = e => {
			self.params.id = e
			self.get()
		}
	}

	if ( self.params.sort.field && !self.params.sort.type ) {
		self.params.sort.type = 'desc'
	}
	
	if (CollectionColumn[opts.name]) {
		opts.columns = CollectionColumn[opts.name]
	}

	for(var i = 0; i < opts.columns.length; i++){
		self.cellnames.push(opts.columns[i].id)
		self.headnames.push(opts.columns[i].name)
	}

	//отрисовка
	self.one('mount', () => {
		if (self.opts.localdata) return;

		RiotControl.trigger("init", clone(self.params))
	})

	//Обновление
	self.Refresh = () => {
		RiotControl.trigger("update", self.params)
	}

	self.get = () => {
		RiotControl.trigger("get", clone(self.params))
	}
	
	//удаление
	self.one('unmount', () => {
		if (self.opts.localdata) return; 
		
		RiotControl.trigger("clear")
		control.OFF()
	})

	if (opts.localdata) {
		self.data = opts.localdata
	} else {

		control.ON("loadcomplete_" + opts.name, e => {
			console.log("loadcomplete")
			if(jSonCmpWithNewObject(e.params, self.params)){
				self.data = e.data
				self.params._key = e.params._key

		    	self.update()

				this.flag && self.setColumnWidths()

				this.flag = false
			}
		})
		
		control.ON("loadpage_" + opts.name, e => {
			if(jSonCmpWithNewObject(e.params, self.params)){
				self.data = self.data.concat(e.data)
                self.update()
			}
		})
	}

	this.onscroll = e => {
		e.preventUpdate = true
		var scrollPos, targetHeight;

  		//Если не виртуально, то ничего не делаем в конце скрола
		if (!self.params.paging) return;

		if (!self.div) {
  			self.div = e.currentTarget;
		}

		if (self.div.scrollLeft != scrollLeft) {
            scrollLeft = self.div.scrollLeft;
            self.table.firstElementChild.scrollLeft = scrollLeft
            return;
        }
		 scrollPos = self.div.scrollTop + self.div.clientHeight;
	     targetHeight = self.div.scrollHeight - scrollPos;

  		if (targetHeight <= self.div.clientHeight ) {
			RiotControl.trigger("newpage", clone(self.params))
		}
  	}

  	this.setRowWidth = () => {
  		this.rowWidth = 0
		for (var i in self.settings) {
			this.rowWidth += Number(self.settings[i].substring(0, self.settings[i].length - 2))
		}
		this.rowWidth = Math.round(this.rowWidth)
		this.rowWidth += 'px'
  	}

  	this.onmousedown = e => {
  		e.preventUpdate = true
  		self.start = e.item;
		self.pressed = true;
		self.startX = e.pageX;
  	}

  	this.on('update', () => {
  		if ( !Object.keys(self.settings).length ) {
  			this.setColumnWidths()
  		}
  	})

  	this.onmouseup = e => {
  		e.preventUpdate = true
  		
  		var tableBody = self.table.lastElementChild,
  		    tableHead  = self.table.firstElementChild

  		if(self.pressed) {

  			var names  = self.cellnames,
  				length = names.length,
  				px = self.settings[names[self.start.i]],
  				tableWidth = self.table.lastElementChild.clientWidth,
  				scrollWidth = tableBody.offsetWidth - tableWidth
  				summ  = 0,
  				width = 0
  				
  			tableHead.lastElementChild.lastElementChild.style.flexBasis = scrollWidth + "px"

  			px = Number(px.substring(0, px.length - 2)) + (e.pageX - self.startX)

  			if ( px < 82 ) px = 82

  			self.settings[names[self.start.i]] = px + "px"

  			for(var i = 0; i < length; i++) {
  				summ += Number(self.settings[names[i]].substring(0, self.settings[names[i]].length - 2))
  			}

  			if( tableWidth - summ > 0){
  				width = Number(self.settings[names[length-1]]
  						.substring(0, self.settings[names[length-1]].length - 2)) + tableWidth - summ
  				self.settings[names[length-1]] = width + "px"
  			}

  			//Проставляем ширину строк
  			this.setRowWidth()

			self.update()
			self.pressed = false;

			self.setToStorage()
		}
  	}

  	this.setColumnWidths = () => {
  		
  		var component = self.getFromStorage()
  			if (component && component.columns) {
	  			self.settings = component.columns

	  			//Проставляем ширину строк
	  			this.setRowWidth()

	  			self.update()
	  			return;
	  		}


  		var tableBody 	= self.table.lastElementChild,
  			tableHead 	= self.table.firstElementChild,
  		    tableWidth  = tableBody.clientWidth,
  		    scrollWidth = tableBody.offsetWidth - tableWidth,
  		    array       = [],
  		    summ        = 0,
  		    k           = 0
  		    
	    if (!tableWidth) return 
	   
		tableHead.lastElementChild.lastElementChild.style.width = scrollWidth + "px"
  		
		for ( var i = 0; i < self.opts.columns.length; i++) {

			var c = self.opts.columns[i]
			if ( !c.width ) {
				array.push(c.id)
			} else {

				if( c.width[c.width.length-1] == "%" ) {
					k = (c.width.substring(0, c.width.length - 1) * tableWidth) / 100
					summ += k
					self.settings[c.id] = k + "px"
				} else {

					self.settings[c.id] = c.width

					if ( Number(c.width) ) {
						summ += Number(self.settings[c.id])
						self.settings[c.id] += "px"
					} else {
						summ += Number(c.width.substring(0, c.width.length - 2))
					}
				}
			}
		}

		if ( array.length ) {
			if ( tableWidth > summ ) {
				summ = (tableWidth - summ) / (array.length) + "px"
			} else {
				summ = "150px"
			}
			for(var i = 0; i < array.length; i++) {
				self.settings[array[i]] = summ 
			}
		}
		this.rowWidth = tableWidth + 'px'

		this.update()
  	}

  	this.getFromStorage = () => {

  		if(!localStorage['grid']) return null
  			
		var settings = JSON.parse(localStorage['grid'])

		if( settings[self.componentHash] ) {
			return settings[self.componentHash]
		}
		return null
  	}

  	this.setToStorage = () => {
  		if( !localStorage['grid'] ) {
			var obj = {}
			obj[self.componentHash] = {
				columns: self.settings
			}
			localStorage['grid'] = JSON.stringify(obj)
		} else {
			var obj = JSON.parse(localStorage['grid'])
			obj[self.componentHash] = {
				columns: self.settings
			}
			localStorage['grid'] = JSON.stringify(obj)
		}
  	}
	</script>
</grid>