(($, window, undefined_) ->
  deepCopy = (source, destination, depth, max) ->
    return destination if depth > max
    for property of source
      if property of destination
        destination[property] = deepCopy(source[property], destination[property], depth + 1, max) if typeof (source[property]) is "object"
      else
        destination[property] = source[property]
    destination

  css3Carousel = (selector, options) ->
    element = $(selector)
    return if not element or not element.length
    options = options or {}
    defaults =
      start: 0
      interval: 5000
      autoplay: true
      item: ".css3-carousel-item"
      base: ""
      position:
        prevPrevPrev: "css3-carousel-visibility-hidden"
        prevPrev: "css3-carousel-visibility-hidden"
        prev: "css3-carousel-visibility-hidden"
        current: "css3-carousel-visibility-visible"
        next: "css3-carousel-visibility-hidden"
        nextNext: "css3-carousel-visibility-hidden"
        nextNextNext: "css3-carousel-visibility-hidden"
        default: "css3-carousel-visibility-hidden"

      direction:
        forward: "css3-carousel-direction-forward"
        reverse: "css3-carousel-direction-reverse"

      control:
        next: ".css3-carousel-control.css3-carousel-control-next"
        prev: ".css3-carousel-control.css3-carousel-control-prev"

    options = deepCopy(defaults, options or {}, 0, 3)
    element.addClass options.base  if options.base
    classesToRemove = Object.keys(options.position).map((key) ->
      options.position[key]
    ).join(" ")
    scope =
      elements: 0
      position: options.start


    # adds +1 to the position
    nextPosition = (position, n) ->
      (position + (n or 1)) % scope.elements


    # adds -1 to the position
    prevPosition = (position, n) ->
      (position - (n or 1) + scope.elements) % scope.elements


    # returns the class of the position
    positionClass = (position) ->
      pos = scope.position

      # switch in order to find the most relevant case:
      switch true

        # if position is the current position
        when position is pos
          options.position.current

        # if position is right before current position:
        when position is prevPosition(pos, 1)
          options.position.prev

        # if position is right after current position:
        when position is nextPosition(pos, 1)
          options.position.next

        # if position is 2 before current position:
        when position is prevPosition(pos, 2)
          options.position.prevPrev

        # if position is 3 before current position:
        when position is prevPosition(pos, 3)
          options.position.prevPrevPrev

        # if position is 2 after current position:
        when position is nextPosition(pos, 2)
          options.position.nextNext

        # if position is 3 after current position:
        when position is nextPosition(pos, 3)
          options.position.nextNextNext

        # if neither:
        else
          options.position["default"]

    updateClasses = ->
      items = $(options.item, element)
      scope.elements = items.length
      items.each (position) ->
        $(this).removeClass(classesToRemove).addClass positionClass(position)

    autoplay = timer: `undefined`
    interval = ->
      api.next()

    start = ->
      return if autoplay.timer
      autoplay.timer = setInterval(interval, options.interval)

    stop = ->
      return unless autoplay.timer
      autoplay.timer = clearInterval(autoplay.timer)

    api =
      prev: ->
        scope.position = prevPosition(scope.position)
        scope.direction = options.direction.reverse
        element.removeClass(options.direction.forward).addClass options.direction.reverse
        updateClasses()

      next: ->
        scope.position = nextPosition(scope.position)
        scope.direction = options.direction.forwards
        element.removeClass(options.direction.reverse).addClass options.direction.forward
        updateClasses()

      update: updateClasses
      start: start
      stop: stop

    $(options.control.next).click (event) ->
      event.stopPropagation()
      api.stop()
      api.next()

    $(options.control.prev).click (event) ->
      event.stopPropagation()
      api.stop()
      api.prev()

    updateClasses()
    start()  if options.autoplay
    api

  $.fn.css3Carousel = (options) ->
    @each (index, selector) ->
      plugin = new css3Carousel(selector, options)
      $(selector).data "css3Carousel", plugin

    this

  $ ->
    $(".css3-carousel").css3Carousel()

) jQuery, window