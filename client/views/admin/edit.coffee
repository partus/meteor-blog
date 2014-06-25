aceLoaded=false 
Template.blogAdminEdit.rendered = ->
  rendered = ->
    aceLoaded=true
    console.log "rendered func called"
    @editor = ace.edit 'editor'
    # @editor.setTheme 'ace/theme/chrome'
    @editor.setFontSize 14
    @editor.renderer.setShowPrintMargin false
    @editor.renderer.setShowGutter false
    @editor.setHighlightActiveLine true
    # @editor.getSession().setMode 'ace/mode/markdown'
    @editor.getSession().setUseWrapMode true

    @editor.on 'change', _.debounce((e) =>
      height = @editor.getSession().getDocument().getLength() * @editor.renderer.lineHeight + @editor.renderer.scrollBar.getWidth()
      $('#editor, #preview').height height
      @editor.resize()
    , 250)

    $label = $('.body-label')
    $switch = $('.make-switch')
    $editor = $('#editor')
    $preview = $('#preview')
    $document = $(document)

    $switch.bootstrapSwitch().on 'switch-change', (e, data) =>
      if data.value
        $editor.hide()
        val = marked @editor.getValue()
        $label.text 'Preview'
        return $preview.html(val).show()

      $editor.show()
      @editor.focus()
      @editor.getSelection().clearSelection()
      $label.text 'Body'
      $preview.hide()

    @editor.setValue @data.body
    @editor.focus()
    @editor.getSelection().clearSelection()

    # Logic for the keyboard preview shortcut: some browsers work on 'keyup', and
    # some on 'keydown', and some on both, but we don't want to toggle it twice so
    # we have these guard variables. Also, use Apple key on Mac, and Ctrl key
    # otherwise.

    justpressed = justtoggled = false
    isMac = (window.navigator.platform.toLowerCase().indexOf('mac') >= 0)
    ctrl = if isMac then 'metaKey' else 'ctrlKey'
    if isMac
      $('.ctrl-label').html '&#8984;'

    $document.on 'keyup', (e) ->
      if justpressed and not justtoggled and e[ctrl] and e.which is 80
        e.preventDefault()
        $switch.bootstrapSwitch 'toggleState'
      justpressed = justtoggled = false

    $document.on 'keydown', (e) ->
      justpressed = true
      if e[ctrl] and e.which is 80
        e.preventDefault()
        $switch.bootstrapSwitch 'toggleState'
        justtoggled = true
  if(aceLoaded)
    rendered.apply(@)
  else
    Meteor.Loader.loadJs("/src-min-noconflict/ace.js",rendered.bind(@));

flash = (status) ->
  setTimeout ->
    $('.status').hide().html(status).fadeIn 'slow', ->
      setTimeout ->
        $('.status').fadeOut 'slow'
      , 2500
  , 100

Template.blogAdminEdit.events

  'click .for-deleting': (e, tpl) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @destroy()
      Router.go 'blogAdmin'

  'click .for-publishing': (e, tpl) ->
    e.preventDefault()

    attrs =
      title: $(tpl.find '[name=title]').val()
      tags: Post.splitTags $(tpl.find '[name=tags]').val()
      body: tpl.editor.getValue()
      excerpt: Post.excerpt tpl.editor.getValue()
      updatedAt: new Date()

    if @published
      status = 'Unpublished'
      $(e.currentTarget).html '<i class="icon-globe"> Publish'
      attrs.published = false
      attrs.publishedAt = null

    else
      status = 'Published'
      $(e.currentTarget).html '<i class="icon-globe"> Unpublish'
      attrs.published = true
      attrs.publishedAt = new Date()

    post = @update attrs

    if post.errors
      return alert(_(post.errors[0]).values()[0])

    flash status

  'click .for-saving': (e, tpl) ->
    e.preventDefault()

    post = @update
      title: $(tpl.find '[name=title]').val()
      tags: Post.splitTags $(tpl.find '[name=tags]').val()
      body: tpl.editor.getValue()
      excerpt: Post.excerpt tpl.editor.getValue()
      updatedAt: new Date()

    if post.errors
      return alert(_(post.errors[0]).values()[0])

    flash 'Saved'
