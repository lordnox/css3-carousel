(($, window, undef) ->

  pluginName = "css3Carousel"

  defaults =
    start    : 0
    interval : 5000
    autoplay : true
    item     : ".css3-carousel-item"
    base     : ""
    position :
      "0"     : "css3-carousel-visibility-visible"
      default : "css3-carousel-visibility-hidden"

    direction :
      forward  : "css3-carousel-direction-forward"
      backward : "css3-carousel-direction-backward"

    control   :
      next : ".css3-carousel-control.css3-carousel-control-next"
      prev : ".css3-carousel-control.css3-carousel-control-prev"

  Plugin = (element, options) ->
    return if not element or not element.length

    # Deep-Merge the options
    options = $.extend true, {}, defaults, options or {}

    # collect classes "owned" by this plugin, these will be added and removed
    # based on the state of the plugin
    classesToRemove = Object.keys(options.position).map((key) ->
      options.position[key]
    ).join(" ")

    # current state of the plugin
    scope =
      elements : 0
      position : options.start
      timer    : undefined

    # adds +1 to the position and wraps around
    nextPosition = (position, n) -> (position + (n or 1)) % scope.elements

    # adds -1 to the position and wraps around
    prevPosition = (position, n) -> (position - (n or 1) + scope.elements) % scope.elements

    # returns the class of the position
    positionClass = (position) ->
      delta = position - scope.position

      # check if the delta exists
      return options.position[delta] if options.position[delta]

      # modify to have it be in the correct range
      modded = delta % scope.elements

      # check if the modded version exists
      return options.position[modded] if options.position[modded]

      # if delta as greater than zero
      if delta > 0
        # decrease modded by elements count
        modded -= scope.elements

        # check again
        return options.position[modded] if options.position[modded]

      # else delta is less than zero
      else
        # increase modded by elements count
        modded += scope.elements

        # check again
        return options.position[modded] if options.position[modded]

      # if neither case was a success return the default or an empty string
      options.position["default"] or ''

    # the update function will be called each time a change happens
    update = ->
      # get all items
      items = $(options.item, element)

      # update the elements count
      scope.elements = items.length

      # update all items individually
      items.each (position) ->
        $(this)
          # by removing all classes
          .removeClass(classesToRemove)
          # and adding the correct one
          .addClass(positionClass position)

    # interval method
    interval = -> api.next()

    # start the autoplay feature
    start = ->
      return if scope.timer
      scope.timer = setInterval interval, options.interval

    # stop the autoplay feature
    stop = ->
      return unless scope.timer
      scope.timer = clearInterval scope.timer

    # define api
    api =
      ###
      # use this to move to a specific position
      # @param position
      # @param direction (true = forward, false = backwards)
      ###
      pos: (position, direction = true) ->
        # set the new current position
        scope.position  = position

        # set the current direction
        scope.direction = if direction then options.direction.forward else options.direction.backward

        # find class to be removed
        rmClass = if not direction then options.direction.forward else options.direction.backward

        # update the directional classes
        element.removeClass(rmClass).addClass scope.direction

        # run the updater
        update()

      # shorthand to move one position backward
      prev: ->
        api.pos prevPosition(scope.position), false

      # shorthand to move one position forward
      next: ->
        api.pos prevPosition(scope.position), true

      # link the api methods
      update : update
      start  : start
      stop   : stop

    # stop the event propagation
    clickHandler = (fn) -> (event) ->
      event.stopPropagation()
      api.stop()
      fn.call @, event

    # register the control buttons
    $(options.control.next).click clickHandler api.next
    $(options.control.next).click clickHandler api.prev

    # run the first update to setup all classes (direction will NOT be set)
    update()

    # start the interval handler
    start() if options.autoplay

    # return the api
    api

  $.fn[pluginName] = (options) ->
    @each (index, selector) ->
      plugin = new Plugin $(@), options
      $(selector).data pluginName, plugin
    # return for jQuery chaining
    @

  # very simple on-ready call, no fancy data-attribute options
  $ -> $(".css3-carousel").css3Carousel()

) jQuery, window