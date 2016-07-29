<alert class="alert g-alert {class}  { g-hidden: flag}" onclick="{click}">
    <!-- <a href="#" class="close" data-dismiss="alert" aria-label="close" >&times;</a> -->
    <b>{type}</b> 
    <span>{text}</span>

    <script>
        var self = this
        var classes = {
            success:'alert-success',
            info   :'alert-info',
            warning:'alert-warning',
            danger :'alert-danger'
        }

        this.class = ''
        this.text = ''
        this.type = ''
        this.flag = true
        this.interval = 0

        window.alert.message = e => {
            this.class = classes[e.type] || 'alert-info'
            this.text = e.text || ''
            this.type = e.type || 'alert-info'
            self.flag = false
            
            this.interval = setTimeout(() => {
                self.close()
            }, (e.time || 2000))

            this.update()

        }

        click (e) {
            e.preventDefault()
            this.close()
        }

        this.close = () => {
            clearInterval(this.interval)
            this.class = ''
            this.text = ''
            this.type = ''
            self.flag = false
            self.update()
        }
        
    </script>
</alert>
