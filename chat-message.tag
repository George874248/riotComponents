<chat-message class={
    chat__message: true,
    chat__message_from: opts.user === from,
    chat__message_to: opts.user !== from }>

    <div class="chat__message-date">{ moment(timestamp).format('LLL') }</div>
    <div class="chat__message-content">
        <div class="chat__message-author">{from} ({name})</div>
        <div class="chat__message-text">{text}</div>
    </div>
</chat-message>
