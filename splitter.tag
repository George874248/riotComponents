<splitter name='splitter' onmouseup={onmouseup}>
	<yield/>
	<script>
        var self = this
		this.move = false
        this.splitterWidth = 4
        self.press = false

        this.on('mount', () => {
            this.init();
		})

        this.init = () => {
            if (this.root.attributes.orientation && this.root.attributes.orientation.value == "horizontal") {
                this.type = 'height'
                this.container = this.root.parentNode.clientHeight
                this.shadowOrientation = 'top'
                this.client = 'clientHeight'
                this.mouseType = 'clientY'
            } else {
                this.type = 'width'
                this.client = 'clientWidth'
                this.container = this.root.clientWidth
                this.shadowOrientation = 'left'
                this.mouseType = 'clientX'

                /*window.onresize = function(event) {
                    console.log(event)
                    self.init()
                }*/
            }

            var tags = this.root.children,
                noWidth = [], 
                containersSize = 0

            // проставляем
            for (var i = 0; i < tags.length; i++) {
                if ( !tags[i].attributes[this.type] || tags[i].attributes[this.type].value == 'auto') {
                    noWidth.push(i)
                } else {
                    var value = this.checkFormat(tags[i].attributes[this.type].value, this.container)

                    containersSize += value
                    value = this.checkValue(value, i, tags.length)

                    tags[i].style[this.type] = value + 'px'
                }
            }

            var ost = (this.container - containersSize) / noWidth.length

            //Проставляем оставшиеся ширины
            noWidth.forEach(index => {
                tags[index].style[this.type] = this.checkValue(ost, index, tags.length) + 'px'

                console.log(this.checkValue(ost, index, tags.length))
            })

            // splitter
            for (var i = 0; i < tags.length - 1; i++) {
                var div = document.createElement("div")
                div.className = 'splitter__divider'

                div.onmousedown = e => {
                    
                    self.press = true
                    
                    document.addEventListener("mousemove", this.move);
                    
                    e.preventUpdate = true
                    e.preventDefault()
                    this.clickedSplitter = e
                    this.startCoord = e[this.mouseType] 

                    this.next = e.target.nextElementSibling
                    this.prev = e.target.previousElementSibling
                }

                this.root.insertBefore(div, tags[i+1])
                i++
            }

            this.splitterShadow = document.createElement("div")
            this.splitterShadow.className = 'splitter__shadow'
            this.splitterShadow.style.display = 'none'
            this.root.appendChild(this.splitterShadow)
        }

        this.checkValue = (value, index, length ) => {
            if (index == 0 || length - 1 == index) {
                return value -= this.splitterWidth / 2
            } 
            return value -= this.splitterWidth
        }

        this.checkFormat = (value, width) => {
            var percent = value.substr(-1, 2)
            if (percent == "x") return Number(value.substring(0, value.length - 2))
            if (percent == "%") return (Number(value.substring(0, value.length - 1)) * width) / 100
            return Number(value)
        }

        this.move = e => {
            if (this.press) {
                e.preventDefault()
                if (this.splitterShadow.style.display != 'block') this.splitterShadow.style.display = 'block'

                var ost = this.startCoord - e[this.mouseType],
                    nextSize = this.next[this.client] + ost,
                    prevSize = this.prev[this.client] - ost

                if (this.checkMinMax(this.next, nextSize, this.prev, prevSize, this.container)) return
                this.splitterShadow.style[this.shadowOrientation] = prevSize + 'px'
            }
        }
      
        this.onmouseup = e => {
            e.preventUpdate = true

            if (!self.press) return
            
            document.removeEventListener('mousemove', this.move)

            this.splitterShadow.style.display = 'none'
            self.press = false

            var ost = this.startCoord - e[this.mouseType],
                width    = this.next[this.client] + this.prev[this.client],
                nextSize = this.next[this.client] + ost,
                prevSize = this.prev[this.client] - ost


            if (this.next[this.client] + ost > width || this.prev[this.client] - ost < 1 || this.prev[this.client] - ost > width) return

            // проверяем попадает ли в ограничения
            if (this.checkMinMax(this.next, nextSize, this.prev, prevSize, this.container)) {
                this.setMinMax(this.next, nextSize, this.prev, prevSize, this.container)
                return
            }

            this.next.style[this.type] = nextSize + 'px'
            this.prev.style[this.type] = prevSize + 'px'
        }

        this.checkMinMax = (next, nextSize, prev, prevSize, splwidth) => {
            if (next.attributes.min && this.checkFormat(next.attributes.min.value, splwidth) > nextSize ||
                next.attributes.max && this.checkFormat(next.attributes.max.value, splwidth) < nextSize ||
                prev.attributes.min && this.checkFormat(prev.attributes.min.value, splwidth) > prevSize || 
                prev.attributes.max && this.checkFormat(prev.attributes.max.value, splwidth) < prevSize) return true
            return false
        }

        this.setMinMax = (next, nextSize, prev, prevSize, splwidth) => {
            if (next.attributes.min && this.checkFormat(next.attributes.min.value, splwidth) > nextSize) {
                nextSize = this.checkFormat(next.attributes.min.value, splwidth)
                prevSize = splwidth - nextSize - this.splitterWidth
            }
            if (next.attributes.max && this.checkFormat(next.attributes.max.value, splwidth) < nextSize) {
                nextSize = this.checkFormat(next.attributes.max.value, splwidth)
                prevSize = splwidth - nextSize - this.splitterWidth
            }
            if (prev.attributes.min && this.checkFormat(prev.attributes.min.value, splwidth) > prevSize) {
                prevSize = this.checkFormat(prev.attributes.min.value)
                nextSize = splwidth - prevSize - this.splitterWidth
            }

            if (prev.attributes.max && this.checkFormat(prev.attributes.max.value, splwidth) < prevSize) {
                prevSize = this.checkFormat(prev.attributes.max.value)
                nextSize = splwidth - prevSize - this.splitterWidth
            }

            this.next.style[this.type] = nextSize + 'px'
            this.prev.style[this.type] = prevSize + 'px'
        }
	</script>
</splitter>