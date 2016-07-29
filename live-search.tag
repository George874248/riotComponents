<live-search-li >
	this.root.innerHTML = this.opts.value.display
</live-search-li>

<live-search>
	<div class="live-search" name="container">
		<div class="live-search__input">
			<input 
				type="text" 
				class="form-control" 
				onkeydown={ handleKeys }
				onkeyup={ handleKeyup }
				placeholder="Адрес"
				name="textinput">
		</div>

		<ul class="dropdown-menu g-block" if="{ isvisible }">
			<li each="{item, i in array }" class={ hover: active == i} onclick={ select } >
				<a href="#">
					<live-search-li value={item}></live-search-li>
				</a>
			</li>
		</ul>
	</div>

	<script>

		this.mixin('riotControl')

        var control = this.riotControl()

		var self = this
		
		this.isvisible = false
		this.selected_address = null
		this.delFlag = 0

		this.params = {
			name: "search",
			url: "/taxi/public/",
			queryparametr: {
				name: "pattern",
				value: ''
			}
		}

		this.houseParams = {
			name: "address/search/",
			id: null
		}

		this.open = () => {
		    this.isvisible = true
		}

		this.close = () => {
			this.active = null
			this.isvisible = false
		}

		this.address_row_bloks = 0

		this.handleKeyId = {
			49: 1,
			50: 2,
			51: 3,
			52: 4,
			53: 5
		}

		this.handleKeyup = e => {
			var value = e.target.value, length = this.container.children.length, k
				
			this.address_row_bloks = length

			if (value == "") this.delFlag++
			else this.delFlag = 0

			value = value.trim()
		
			if (e.keyCode == 8 && this.delFlag > 1 ) {
				if (length > 2 && this.isvisible) {
					k = 3
				} else if (length > 1 && !this.isvisible) {
					k = 2
				}
				
				k && this.container.removeChild(this.container.children[length - k])
				length--
				
				this.setTrueAddress(this.selected, length)
			}

			this.isvisible ? this.address_row_bloks -=2 : this.address_row_bloks--

			if ([13, 38, 40, 37, 39, 36, 35].indexOf(e.keyCode) > -1) return true

			clearInterval(this._timer)
			this._timer = setTimeout(() => {

				if( !value ) {
					this.close()
					this.update()
					return
				}

				var prevstr = ""
				if (this.address_row_bloks) {
					for (var i = 0; i < this.address_row_bloks; i++) {
						prevstr += this.container.children[i].innerText + " "
					}
				}

				this.params.queryparametr.value = prevstr + value
				RiotControl.trigger("get", clone(this.params))
	        }, 300)
		}

		this.handleKeys = e => {
			
			var key = e.keyCode

			if (e.altKey) {
				var num = this.handleKeyId[key],
					load = "load_order_history_"

				if (key == 18 || !num) return true

				var self = this;

				function loadHistory (data) {
					self.select({
						item: data
					})

					RiotControl.off(load + num, loadHistory)
				}

				RiotControl.on(load + num, loadHistory)
				RiotControl.trigger("get_order_history", num)
			}


			if (key == 13 || key == 9) {
				if (this.active || this.active == 0 && this.array[this.active]) {
					this.select(this.array[this.active]) 
				}
				return true
			}

			if ([38, 40].indexOf(key) == -1 || this.isvisible == false) {
				return true
			}

			if (key == 38) {   //вверх
				
				if (this.active || this.active == 0) {
					if (this.active != 0) this.active--
				} else {
					if (this.selected || this.selected == 0) {
						if (this.selected != 0) {
							this.active = this.selected - 1
						}
					} else {
						this.active = this.array.length - 1
					}
				}
			} else if (key == 40) {      //вниз
				
				if (this.active || this.active == 0) {
					if (this.active != this.array.length - 1) this.active++
				} else {
					if (this.selected || this.selected == 0) {
						if (this.selected != this.array.length - 1) {
							this.active = this.selected + 1
						}
					} else this.active = 0;
				}
			} else {
				if (this.active || this.active == 0) {
					this.tagvalue = this.data[this.active].data
					this.close()
				}
			}
		} 



		this.setTrueAddress = (address, index) => {
			var objCustom = {
				4: "address",
				3: "street",
				2: "city",
				1: "region"
			},
			objectFast = {
				4: "house",
				3: "street",
				2: "town",
				1: "region"
			};

			var adr = address;


			//debugger
			if (address.hasOwnProperty("address") && !address.hasOwnProperty("id")) {
				address[objCustom[index]] = ""
			}

			if (address.hasOwnProperty("id")) adr = adr.address;

			adr[objectFast[index]] = ""

			adr.x = 0
			adr.y = 0

			this.select( {item: address })
			return true
		}

		control.ON("loadcomplete_" + this.params.name, function(e) {
		
			if (!jSonCmpWithNewObject(e.params, self.params)) return

			self.params._key = e.params._key

			for (var i = 0; i < e.data.addresses.length; i++) {
				if (!e.data.addresses[i].address && e.data.suggestion.house) {
					e.data.addresses[i].address = {
						house: e.data.suggestion.house,
						id: null,
						name: null,
						streetId: null,
						x: 0,
						y: 0
					}
				}
			}


			self.data = e.data.addresses.concat(e.data.objects)

			self.array = self.newDispAdress(self.data, self.address_row_bloks)

			self.active = 0

			for (var i = 0; i < self.array.length; i++) {
				if (!self.array[i].name || self.array[i].name == "") continue
				self.array[i].display = stringmatches(self.array[i].name, self.textinput.value.trim())
			}

			if (self.array.length == 1 && !self.array[0].display) return

			self.array.length ? self.open() : self.close()
			self.update()
		})

		control.ON("loadcomplete_" + this.houseParams.name, function(house_data) {
			if (!jSonCmpWithNewObject(house_data.params, self.houseParams)) return

			self.houseParams._key = house_data.params._key

			if (house_data.data.areaId) {
				self.opts.data.area = house_data.data.areaId
			} 

			self.opts.data.x = house_data.data.x
			self.opts.data.y = house_data.data.y
			self.parent.update()
		})

		control.ON("live_search_update", () => {
			this.select({item: this.opts.data}, true)
		})

		this.newDispAdress = (data, length) => {
			return data.map( item => {
				var str = '';

				if (!item.geoGroupId) {
		    		if(item.region  && length == 0) str += item.region.name +  " ";
		        	if(item.city    && length <= 1) str += item.city.name + " ";
		        	if(item.street  && length <= 2) str += item.street.name + " ";
		        	if(item.address && length <= 3) {
		        		if (item.address.house) {

		        			str += item.address.house;
		        		}
		        	}
		    	} else {
		    		str += item.name + "_" + item.geoGroupId;
		    	}

		    	return {
		    		name: str.trim(),
		    		item: item
		    	}
			});
		}

		this.select = (row, isFirstOpen) => {
			var adress = row.target ? row.item.item.item : row.item, span, k

			this.delFlag = 0

			this.textinput.value = ""

			this.selected = clone(adress)

			k = this.isvisible ? 2 : 1

			this.close()

			while (this.container.children.length != k) {
				this.container.removeChild(this.container.children[0])
			}

			var customFields = ["house", "street", "town", "region"]
			//debugger
			// заказ - история
			if (adress.hasOwnProperty("area")) {
				//debugger
				this.insAftaddress(customFields, adress, this.container)
				
				for (var i in adress) {
					this.opts.data[i] = adress[i]
				}

				//this.opts.data = Object.assign({}, adress)

				if (adress.street) {
					this.opts.data.name = adress.street
					if (adress.house) {
						this.opts.data.name += ", " + adress.house
					}
				} else {
					this.opts.data.name = ""
				}
			} else

			// быстрый адрес
			if (adress.hasOwnProperty("geoGroupId")) {
				this.insAftaddress(customFields, adress.address, this.container)

				var arr = ["area", "housing", "y", "x"]

				arr.forEach(item => {
					this.opts.data[item] = adress.address[item]
				})

				if (adress.address.street) {
					this.opts.data.name = adress.address.street
					if (adress.address.house) {
						this.opts.data.name += ", " + adress.address.house
					}
				} else {
					this.opts.data.name = ""
				}

				this.opts.data.comment = adress.name
			} else

			// обычный адрес
			if (adress.hasOwnProperty("city")) {

				var obj = {
					region : adress.region && adress.region.name,
					town   : adress.city   && adress.city.name,
					street : adress.street && adress.street.name
				}

				this.opts.data.area = adress.street ? adress.street.areaId : ''

				if (adress.address) {
					
					obj.house = adress.address.house

					this.insAftaddress(customFields, obj, this.container)

					this.opts.data.x = adress.address.x
					this.opts.data.y = adress.address.y


					if (obj.street) {
						this.opts.data.name = obj.street
						if (obj.house) {
							this.opts.data.name += ", " + obj.house
						}
					} else {
						this.opts.data.name = ""
					}

					this.houseParams.id = adress.street.id + "/" + adress.address.house

					RiotControl.trigger("get", clone(this.houseParams))

				} else {
					
					this.insAftaddress(["street", "town", "region"], obj, this.container)

					this.opts.data.name = obj.street
					//this.opts.data.area = adress.street ? adress.street.areaId : ''
					this.opts.data.house = ''
					this.opts.data.x = 0
					this.opts.data.y = 0
				}

			}

			if (this.opts.data.name && this.opts.data.name.trim() || this.opts.data.town) {
				if (!isFirstOpen) {
					RiotControl.trigger("calculate")
				}
			} 

			this.parent.update()
		}

		this.insAftaddress = (fields, address, container) => {
			
			fields.forEach(field => {
				var span = document.createElement("span"),
					town = (field == "city") ? "town" : field
					
				span.innerText = address[field] && address[field].name || address[field]

				this.opts.data[town] = span.innerText

				address[field] && container.insertBefore(span, container.children[0])
			})
		}

		const handleClickOutside = e => {
			if (!this.root.contains(e.target)) this.close()
			this.update()
		}

		this.on("mount", () => {
			document.addEventListener('click', handleClickOutside)
		})

		this.on('unmount', () => {
			document.removeEventListener('click', handleClickOutside)
			control.OFF()
		})
		
	</script>
</live-search>