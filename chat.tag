<chat>
    <ul id="chatTabs" class="tabs__head">
        <li  onclick={changeTab} name="global" class={ active: tab === "global"}>
            <span class="tab__title">Общий чат</span>
            <span class="tab__title_info"></span>
        </li>
        <li  onclick={changeTab} name="driver" class={ active: tab === "driver"} if={driverId}>
            <span class="tab__title">{driverId}</span>
            <span class="tab__title_info"></span>
        </li>
    </ul>
    <div class="tabs__body chat__body">
            <div class={chat__tab: true, active: tab === "global"}>
                <div class="chat__history" name="globalWrapper">
                    <chat-message no-reorder each={globalChat} user={parent.user}/>
                </div>
            </div>

            <div class={chat__tab: true, active: tab === "driver"} if={driverId} >
                <div class=" chat__preloader sk-three-bounce" show={driverSettings.loading}>
                    <div class="sk-child sk-bounce1"></div>
                    <div class="sk-child sk-bounce2"></div>
                    <div class="sk-child sk-bounce3"></div>
                </div>
                <div class="chat__history" name="driverWrapper" onscroll={driverScroll}>
                      <chat-message no-reorder each={driverChat}  user={parent.user}/>
                </div>
                <div>
                    <div class="chat__send-form">
                        <textarea class="chat__send-content" name="chatText" onkeyup={chatKeyUp}></textarea>
                        <button class="chat__send-btn" onclick={sendMessage}>
                            <i class="fa fa-bullhorn"></i>
                        </button>
                    </div>
                </div>
            </div>
    </div>
    <script>
        var height;
        this.user = JSON.parse(getCookie('userInfo')).id;
        this.tab = 'global';
        this.driverId = null;
        this.globalChat = [];
        this.driverChat = [];
        this.globalSettings = {
            url: '/taxi/rest/chat/@',
            skip: 0,
            limit: 150,
            sort: {
            field:'timestamp',
                type: 'desc'
            },
            paging:true,
            callback:  (res) => {
                this.globalChat = res.reverse();
                this.update();
                this.setScrollTop(this.globalWrapper);
            }
        };
        this.driverSettings = {
            url: 'chat/',
            skip: 0,
            limit: 50,
            sort: {
                field:'timestamp',
                type: 'desc'
            },
            paging:true,
            loading: false,
            callback: (res) => {
                var settings = this.driverSettings;
                    settings.loading = false;

                if (res.length) {
                    var messagges = res.reverse();
                    this.tab = 'driver';
                    this.driverChat = messagges.concat(this.driverChat);
                    this.update();
                    settings.skip === 0 ? this.setScrollTop(this.driverWrapper)
                                        : this.setScrollTop(this.driverWrapper, 'top');
                    this.setScrollHeight(this.driverWrapper);
                    settings.skip += settings.limit;
                } else {
                    this.update();
                    settings.loading = true;
                }
            }
        };

        setScrollTop (el, param) {
            if (param) {
                el.scrollTop = el.scrollHeight - height;
            } else {
                el.scrollTop = el.scrollHeight - el.clientHeight;
            }
        }

        setScrollHeight(el) {
            height =  el.scrollHeight;
        }

        changeTab (e) {
            this.tab = e.currentTarget.getAttribute("name");
        }

        driverScroll (e) {
            e.preventUpdate = true;
            var scrollPos = e.currentTarget.scrollTop;

            if (scrollPos === 0 && !this.driverSettings.loading ) {
                this.driverSettings.loading = true;
                this.update();
                RiotControl.trigger('get_only', this.driverSettings);
            }
        }

        chatKeyUp (e) {
            e.preventUpdate = true;

            if (e.which === 13) {

                if (!e.shiftKey) {
                    this.sendMessage();
                }
            }
        }

        sendMessage (e) {
            if (e) e.preventUpdate = true;

            var text = this.chatText.value.trim();

            if (text) {
                RiotControl.trigger('post_only',  {
                    url: `/taxi/rest/chat/${this.driverId}`,
                    data:  { text: text },
                    callback: (err, res) => {
                        if (err) {
                            console.log(err);
                        } else {
                            this.chatText.value = '';
                            this.update();
                        }
                    }
                });
            }
        }

        notify (message) {

            if (("Notification" in window)) {

                if (Notification.permission == "granted" ) {
                    var header = 'Новое сообщение от ' + message.from
                    var notification = new Notification(header, {
                        tag: message.from,
                        body: message.text,
                        silent: false
                    });
                    notification.onclick = function () {
                        this.close();
                    };
                    setTimeout(notification.close.bind(notification), 3000);
                }
            }
        }

        RiotControl.on('chat_mesage', (message) => {
            this.globalChat.shift();
            this.globalChat.push(message);

            if (message.from === this.driverId || _.contains(message.to , this.driverId) ) {
                this.driverChat.push(message);
                this.update();
                this.setScrollTop(this.driverWrapper);
                return
            } else if (message.orderId && message.from !== this.user) {
                this.notify(message);
            }
            this.update();
        })


        RiotControl.on('chat_driver_msgs', (driverId) => {

            if (driverId && this.driverId !== driverId) {
                this.driverId = driverId;
                this.driverChat = [];
                this.chatText.value = '';

                RiotControl.trigger('get_only', Object.assign(this.driverSettings, {
                    url: `/taxi/rest/chat/${driverId}`,
                    skip: 0
                }));
            }
        })

        this.on('mount', () => {
            RiotControl.trigger('get_only', this.globalSettings);
        })

        this.on("unmount", () => {
            RiotControl.off('chat_mesage chat_driver_msgs');
        })
    </script>
</chat>