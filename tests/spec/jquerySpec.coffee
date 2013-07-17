describe "jasmine.Fixtures", ->
  ajaxData = "some ajax data"
  fixtureUrl = "some_url"
  anotherFixtureUrl = "another_url"
  fixturesContainer = ->
    $ "#" + jasmine.getFixtures().containerId

  appendFixturesContainerToDom = ->
    $("body").append "<div id=\"" + jasmine.getFixtures().containerId + "\">old content</div>"

  beforeEach ->
    jasmine.getFixtures().clearCache()
    spyOn(jasmine.Fixtures::, "loadFixtureIntoCache_").andCallFake (relativeUrl) ->
      @fixturesCache_[relativeUrl] = ajaxData


  describe "default initial config values", ->
    it "should set 'jasmine-fixtures' as the default container id", ->
      expect(jasmine.getFixtures().containerId).toEqual "jasmine-fixtures"

    it "should set 'spec/javascripts/fixtures' as the default fixtures path", ->
      expect(jasmine.getFixtures().fixturesPath).toEqual "spec/javascripts/fixtures"


  describe "cache", ->
    describe "clearCache", ->
      it "should clear cache and in effect force subsequent AJAX call", ->
        jasmine.getFixtures().read fixtureUrl
        jasmine.getFixtures().clearCache()
        jasmine.getFixtures().read fixtureUrl
        expect(jasmine.Fixtures::loadFixtureIntoCache_.callCount).toEqual 2


    it "first-time read should go through AJAX", ->
      jasmine.getFixtures().read fixtureUrl
      expect(jasmine.Fixtures::loadFixtureIntoCache_.callCount).toEqual 1

    it "subsequent read from the same URL should go from cache", ->
      jasmine.getFixtures().read fixtureUrl, fixtureUrl
      expect(jasmine.Fixtures::loadFixtureIntoCache_.callCount).toEqual 1


  describe "read", ->
    it "should return fixture HTML", ->
      html = jasmine.getFixtures().read(fixtureUrl)
      expect(html).toEqual ajaxData

    it "should return duplicated HTML of a fixture when its url is provided twice in a single call", ->
      html = jasmine.getFixtures().read(fixtureUrl, fixtureUrl)
      expect(html).toEqual ajaxData + ajaxData

    it "should return merged HTML of two fixtures when two different urls are provided in a single call", ->
      html = jasmine.getFixtures().read(fixtureUrl, anotherFixtureUrl)
      expect(html).toEqual ajaxData + ajaxData

    it "should have shortcut global method readFixtures", ->
      html = readFixtures(fixtureUrl, anotherFixtureUrl)
      expect(html).toEqual ajaxData + ajaxData

    it "should use the configured fixtures path concatenating it to the requested url (without concatenating a slash if it already has an ending one)", ->
      jasmine.getFixtures().fixturesPath = "a path ending with slash/"
      expect(jasmine.getFixtures().makeFixtureUrl_(fixtureUrl)).toEqual "a path ending with slash/" + fixtureUrl

    it "should use the configured fixtures path concatenating it to the requested url (concatenating a slash if it doesn't have an ending one)", ->
      jasmine.getFixtures().fixturesPath = "a path without an ending slash"
      expect(jasmine.getFixtures().makeFixtureUrl_(fixtureUrl)).toEqual "a path without an ending slash/" + fixtureUrl


  describe "load", ->
    it "should insert fixture HTML into container", ->
      jasmine.getFixtures().load fixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData

    it "should insert duplicated fixture HTML into container when the same url is provided twice in a single call", ->
      jasmine.getFixtures().load fixtureUrl, fixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should insert merged HTML of two fixtures into container when two different urls are provided in a single call", ->
      jasmine.getFixtures().load fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should have shortcut global method loadFixtures", ->
      loadFixtures fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    describe "when fixture container does not exist", ->
      it "should automatically create fixtures container and append it to DOM", ->
        jasmine.getFixtures().load fixtureUrl
        expect(fixturesContainer().size()).toEqual 1


    describe "when fixture container exists", ->
      beforeEach ->
        appendFixturesContainerToDom()

      it "should replace it with new content", ->
        jasmine.getFixtures().load fixtureUrl
        expect(fixturesContainer().html()).toEqual ajaxData


    describe "when fixture contains an inline <script> tag", ->
      beforeEach ->
        ajaxData = "<div><a id=\"anchor_01\"></a><script>$(function(){ $('#anchor_01').addClass('foo')});</script></div>"

      it "should execute the inline javascript after the fixture has been inserted into the body", ->
        jasmine.getFixtures().load fixtureUrl
        expect($("#anchor_01")).toHaveClass "foo"



  describe "appendLoad", ->
    beforeEach ->
      ajaxData = "some ajax data"

    it "should insert fixture HTML into container", ->
      jasmine.getFixtures().appendLoad fixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData

    it "should insert duplicated fixture HTML into container when the same url is provided twice in a single call", ->
      jasmine.getFixtures().appendLoad fixtureUrl, fixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should insert merged HTML of two fixtures into container when two different urls are provided in a single call", ->
      jasmine.getFixtures().appendLoad fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should have shortcut global method loadFixtures", ->
      appendLoadFixtures fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should automatically create fixtures container and append it to DOM", ->
      jasmine.getFixtures().appendLoad fixtureUrl
      expect(fixturesContainer().size()).toEqual 1

    describe "with a prexisting fixture", ->
      beforeEach ->
        jasmine.getFixtures().appendLoad fixtureUrl

      it "should add new content", ->
        jasmine.getFixtures().appendLoad fixtureUrl
        expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

      it "should not add a new fixture container", ->
        jasmine.getFixtures().appendLoad fixtureUrl
        expect(fixturesContainer().size()).toEqual 1


    describe "when fixture contains an inline <script> tag", ->
      beforeEach ->
        ajaxData = "<div><a id=\"anchor_01\"></a><script>$(function(){ $('#anchor_01').addClass('foo')});</script></div>"

      it "should execute the inline javascript after the fixture has been inserted into the body", ->
        jasmine.getFixtures().appendLoad fixtureUrl
        expect($("#anchor_01")).toHaveClass "foo"



  describe "preload", ->
    describe "read after preload", ->
      it "should go from cache", ->
        jasmine.getFixtures().preload fixtureUrl, anotherFixtureUrl
        jasmine.getFixtures().read fixtureUrl, anotherFixtureUrl
        expect(jasmine.Fixtures::loadFixtureIntoCache_.callCount).toEqual 2

      it "should return correct HTMLs", ->
        jasmine.getFixtures().preload fixtureUrl, anotherFixtureUrl
        html = jasmine.getFixtures().read(fixtureUrl, anotherFixtureUrl)
        expect(html).toEqual ajaxData + ajaxData


    it "should not preload the same fixture twice", ->
      jasmine.getFixtures().preload fixtureUrl, fixtureUrl
      expect(jasmine.Fixtures::loadFixtureIntoCache_.callCount).toEqual 1

    it "should have shortcut global method preloadFixtures", ->
      preloadFixtures fixtureUrl, anotherFixtureUrl
      jasmine.getFixtures().read fixtureUrl, anotherFixtureUrl
      expect(jasmine.Fixtures::loadFixtureIntoCache_.callCount).toEqual 2


  describe "set", ->
    html = "<div>some HTML</div>"
    it "should insert HTML into container", ->
      jasmine.getFixtures().set html
      expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)

    it "should insert jQuery element into container", ->
      jasmine.getFixtures().set $(html)
      expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)

    it "should have shortcut global method setFixtures", ->
      setFixtures html
      expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)

    describe "when fixture container does not exist", ->
      it "should automatically create fixtures container and append it to DOM", ->
        jasmine.getFixtures().set html
        expect(fixturesContainer().size()).toEqual 1


    describe "when fixture container exists", ->
      beforeEach ->
        appendFixturesContainerToDom()

      it "should replace it with new content", ->
        jasmine.getFixtures().set html
        expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)



  describe "appendSet", ->
    html = "<div>some HTML</div>"
    it "should insert HTML into container", ->
      jasmine.getFixtures().appendSet html
      expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)

    it "should insert jQuery element into container", ->
      jasmine.getFixtures().appendSet $(html)
      expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)

    it "should have shortcut global method setFixtures", ->
      appendSetFixtures html
      expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html)

    describe "when fixture container does not exist", ->
      it "should automatically create fixtures container and append it to DOM", ->
        jasmine.getFixtures().appendSet html
        expect(fixturesContainer().size()).toEqual 1


    describe "when fixture container exists", ->
      beforeEach ->
        jasmine.getFixtures().appendSet html

      it "should add new content", ->
        jasmine.getFixtures().appendSet html
        expect(fixturesContainer().html()).toEqual jasmine.JQuery.browserTagCaseIndependentHtml(html) + jasmine.JQuery.browserTagCaseIndependentHtml(html)



  describe "sandbox", ->
    describe "with no attributes parameter specified", ->
      it "should create DIV with id #sandbox", ->
        expect(jasmine.getFixtures().sandbox().html()).toEqual $("<div id=\"sandbox\" />").html()


    describe "with attributes parameter specified", ->
      it "should create DIV with attributes", ->
        attributes =
          attr1: "attr1 value"
          attr2: "attr2 value"

        element = $(jasmine.getFixtures().sandbox(attributes))
        expect(element.attr("attr1")).toEqual attributes.attr1
        expect(element.attr("attr2")).toEqual attributes.attr2

      it "should be able to override id by setting it as attribute", ->
        idOverride = "overridden"
        element = $(jasmine.getFixtures().sandbox(id: idOverride))
        expect(element.attr("id")).toEqual idOverride


    it "should have shortcut global method sandbox", ->
      attributes = id: "overridden"
      element = $(sandbox(attributes))
      expect(element.attr("id")).toEqual attributes.id


  describe "cleanUp", ->
    it "should remove fixtures container from DOM", ->
      appendFixturesContainerToDom()
      jasmine.getFixtures().cleanUp()
      expect(fixturesContainer().size()).toEqual 0



  # WARNING: this block requires its two tests to be invoked in order!
  # (Really ugly solution, but unavoidable in this specific case)
  describe "automatic DOM clean-up between tests", ->

    # WARNING: this test must be invoked first (before 'SECOND TEST')!
    it "FIRST TEST: should pollute the DOM", ->
      appendFixturesContainerToDom()


    # WARNING: this test must be invoked second (after 'FIRST TEST')!
    it "SECOND TEST: should see the DOM in a blank state", ->
      expect(fixturesContainer().size()).toEqual 0



describe "jasmine.Fixtures using real AJAX call", ->
  beforeEach ->
    defaultFixturesPath = jasmine.getFixtures().fixturesPath
    jasmine.getFixtures().fixturesPath = "spec/fixtures"

  afterEach ->
    jasmine.getFixtures().fixturesPath = defaultFixturesPath

  describe "when fixture file exists", ->
    fixtureUrl = "real_non_mocked_fixture.html"
    it "should load content of fixture file", ->
      fixtureContent = jasmine.getFixtures().read(fixtureUrl)
      expect(fixtureContent).toEqual "<div id=\"real_non_mocked_fixture\"></div>"




# TODO : start throwing again
#  describe("when fixture file does not exist", function() {
#    var fixtureUrl = "not_existing_fixture"
#
#    it("should throw an exception", function() {
#      expect(function() {
#        jasmine.getFixtures().read(fixtureUrl)
#      }).toThrow()
#    })
#  })
#
describe "jQuery matchers", ->
  describe "when jQuery matcher hides original Jasmine matcher", ->
    describe "and tested item is jQuery object", ->
      it "should invoke jQuery version of matcher", ->
        expect($("<div />")).toBe "div"


    describe "and tested item is not jQuery object", ->
      it "should invoke original version of matcher", ->
        expect(true).toBe true


    describe "and tested item is a dom object", ->
      it "should invoke jquery version of matcher", ->
        expect($("<div />").get(0)).toBe "div"



  describe "when jQuery matcher does not hide any original Jasmine matcher", ->
    describe "and tested item in not jQuery object", ->
      it "should pass negated", ->
        expect({}).not.toHaveClass "some-class"



  describe "when invoked multiple times on the same fixture", ->
    it "should not reset fixture after first call", ->
      setFixtures sandbox()
      expect($("#sandbox")).toExist()
      expect($("#sandbox")).toExist()


  describe "toHaveClass", ->
    className = "some-class"
    it "should pass when class found", ->
      setFixtures sandbox(class: className)
      expect($("#sandbox")).toHaveClass className
      expect($("#sandbox").get(0)).toHaveClass className

    it "should pass negated when class not found", ->
      setFixtures sandbox()
      expect($("#sandbox")).not.toHaveClass className
      expect($("#sandbox").get(0)).not.toHaveClass className

    it "should not crash when documentElement provided", ->
      doc = $(document.documentElement).addClass(className)
      expect(doc).toHaveClass className
      doc.removeClass className
      expect(doc).not.toHaveClass className


  describe "toHaveAttr", ->
    attributeName = "attr1"
    attributeValue = "attr1 value"
    wrongAttributeName = "wrongName"
    wrongAttributeValue = "wrong value"
    beforeEach ->
      attributes = {}
      attributes[attributeName] = attributeValue
      setFixtures sandbox(attributes)

    describe "when only attribute name is provided", ->
      it "should pass if element has matching attribute", ->
        expect($("#sandbox")).toHaveAttr attributeName
        expect($("#sandbox").get(0)).toHaveAttr attributeName

      it "should pass negated if element has no matching attribute", ->
        expect($("#sandbox")).not.toHaveAttr wrongAttributeName
        expect($("#sandbox").get(0)).not.toHaveAttr wrongAttributeName


    describe "when both attribute name and value are provided", ->
      it "should pass if element has matching attribute with matching value", ->
        expect($("#sandbox")).toHaveAttr attributeName, attributeValue
        expect($("#sandbox").get(0)).toHaveAttr attributeName, attributeValue

      it "should pass negated if element has matching attribute but with wrong value", ->
        expect($("#sandbox")).not.toHaveAttr attributeName, wrongAttributeValue
        expect($("#sandbox").get(0)).not.toHaveAttr attributeName, wrongAttributeValue

      it "should pass negated if element has no matching attribute", ->
        expect($("#sandbox")).not.toHaveAttr wrongAttributeName, attributeValue
        expect($("#sandbox").get(0)).not.toHaveAttr wrongAttributeName, attributeValue



  describe "toHaveProp", ->
    propertyName = "prop1"
    propertyValue = "prop1 value"
    wrongPropertyName = "wrongName"
    wrongPropertyValue = "wrong value"
    beforeEach ->
      setFixtures sandbox()
      element = $("#sandbox")[0]
      element[propertyName] = propertyValue

    describe "when only property name is provided", ->
      it "should pass if element has matching property", ->
        expect($("#sandbox")).toHaveProp propertyName

      it "should pass negated if element has no matching property", ->
        expect($("#sandbox")).not.toHaveProp wrongPropertyName


    describe "when both property name and value are provided", ->
      it "should pass if element has matching property with matching value", ->
        expect($("#sandbox")).toHaveProp propertyName, propertyValue

      it "should pass negated if element has matching property but with wrong value", ->
        expect($("#sandbox")).not.toHaveProp propertyName, wrongPropertyValue

      it "should pass negated if element has no matching property", ->
        expect($("#sandbox")).not.toHaveProp wrongPropertyName, propertyValue



  describe "toHaveCss", ->
    beforeEach ->
      setFixtures sandbox()

    it "should pass if the element has matching css", ->
      $("#sandbox").css "display", "none"
      $("#sandbox").css "margin-left", "10px"
      expect($("#sandbox")).toHaveCss
        display: "none"
        "margin-left": "10px"


    it "should be able to check a subset of element's css", ->
      $("#sandbox").css "display", "none"
      $("#sandbox").css "margin-left", "10px"
      expect($("#sandbox")).toHaveCss "margin-left": "10px"

    it "should fail if the element doesn't have matching css", ->
      $("#sandbox").css "display", "none"
      $("#sandbox").css "margin-left", "20px"
      expect($("#sandbox")).not.toHaveCss
        display: "none"
        "margin-left": "10px"



  describe "toHaveId", ->
    beforeEach ->
      setFixtures sandbox()

    it "should pass if id attribute matches expectation", ->
      expect($("#sandbox")).toHaveId "sandbox"
      expect($("#sandbox").get(0)).toHaveId "sandbox"

    it "should pass negated if id attribute does not match expectation", ->
      expect($("#sandbox")).not.toHaveId "wrongId"
      expect($("#sandbox").get(0)).not.toHaveId "wrongId"

    it "should pass negated if id attribute is not present", ->
      expect($("<div />")).not.toHaveId "sandbox"
      expect($("<div />").get(0)).not.toHaveId "sandbox"


  describe "toHaveHtml", ->
    html = "<div>some text</div>"
    wrongHtml = "<span>some text</span>"
    beforeEach ->
      element = $("<div/>").append(html)

    it "should pass when html matches", ->
      expect(element).toHaveHtml html
      expect(element.get(0)).toHaveHtml html

    it "should pass negated when html does not match", ->
      expect(element).not.toHaveHtml wrongHtml
      expect(element.get(0)).not.toHaveHtml wrongHtml


  describe "toContainHtml", ->
    beforeEach ->
      setFixtures sandbox()

    it "should pass when the element contains given html", ->
      $("#sandbox").html "<div><ul></ul><h1>foo</h1></div>"
      expect($("#sandbox")).toContainHtml "<ul></ul>"

    it "should fail when the element doesn't contain given html", ->
      $("#sandbox").html "<div><h1>foo</h1></div>"
      expect($("#sandbox")).not.toContainHtml "<ul></ul>"


  describe "toHaveText", ->
    text = "some text"
    wrongText = "some other text"
    beforeEach ->
      element = $("<div/>").append(text)

    it "should pass when text matches", ->
      expect(element).toHaveText text
      expect(element.get(0)).toHaveText text

    it "should ignore surrounding whitespace", ->
      element = $("<div>\n" + text + "\n</div>")
      expect(element).toHaveText text
      expect(element.get(0)).toHaveText text

    it "should pass negated when text does not match", ->
      expect(element).not.toHaveText wrongText
      expect(element.get(0)).not.toHaveText wrongText

    it "should pass when text matches a regex", ->
      expect(element).toHaveText /some/
      expect(element.get(0)).toHaveText /some/

    it "should pass negated when text does not match a regex", ->
      expect(element).not.toHaveText /other/
      expect(element.get(0)).not.toHaveText /other/


  describe "toContainText", ->
    text = "some pretty long bits of text"
    textPart = "pret"
    wrongText = "some other text"
    beforeEach ->
      element = $("<div/>").append(text)

    it "should pass when text contains text part", ->
      expect(element).toContainText textPart
      expect(element.get(0)).toContainText textPart

    it "should pass negated when text does not match", ->
      expect(element).not.toContainText wrongText
      expect(element.get(0)).not.toContainText wrongText

    it "should pass when text matches a regex", ->
      expect(element).toContainText /some/
      expect(element.get(0)).toContainText /some/

    it "should pass negated when text does not match a regex", ->
      expect(element).not.toContainText /other/
      expect(element.get(0)).not.toContainText /other/


  describe "toHaveValue", ->
    value = "some value"
    differentValue = "different value"
    beforeEach ->
      setFixtures $("<input id=\"sandbox\" type=\"text\" />").val(value)

    it "should pass if value matches expectation", ->
      expect($("#sandbox")).toHaveValue value
      expect($("#sandbox").get(0)).toHaveValue value

    it "should pass negated if value does not match expectation", ->
      expect($("#sandbox")).not.toHaveValue differentValue
      expect($("#sandbox").get(0)).not.toHaveValue differentValue

    it "should pass negated if value attribute is not present", ->
      expect(sandbox()).not.toHaveValue value
      expect(sandbox().get(0)).not.toHaveValue value

    it "should not coerce types", ->
      setFixtures $("<input id=\"sandbox\" type=\"text\" />").val("")
      expect($("#sandbox")).not.toHaveValue 0


  describe "toHaveData", ->
    key = "some key"
    value = "some value"
    wrongKey = "wrong key"
    wrongValue = "wrong value"
    beforeEach ->
      setFixtures sandbox().data(key, value)

    describe "when only key is provided", ->
      it "should pass if element has matching data key", ->
        expect($("#sandbox")).toHaveData key
        expect($("#sandbox").get(0)).toHaveData key

      it "should pass negated if element has no matching data key", ->
        expect($("#sandbox")).not.toHaveData wrongKey
        expect($("#sandbox").get(0)).not.toHaveData wrongKey


    describe "when both key and value are provided", ->
      it "should pass if element has matching key with matching value", ->
        expect($("#sandbox")).toHaveData key, value
        expect($("#sandbox").get(0)).toHaveData key, value

      it "should pass negated if element has matching key but with wrong value", ->
        expect($("#sandbox")).not.toHaveData key, wrongValue
        expect($("#sandbox").get(0)).not.toHaveData key, wrongValue

      it "should pass negated if element has no matching key", ->
        expect($("#sandbox")).not.toHaveData wrongKey, value
        expect($("#sandbox").get(0)).not.toHaveData wrongKey, value



  describe "toBeVisible", ->
    it "should pass on visible element", ->
      setFixtures sandbox()
      expect($("#sandbox")).toBeVisible()
      expect($("#sandbox").get(0)).toBeVisible()

    it "should pass negated on hidden element", ->
      setFixtures sandbox().hide()
      expect($("#sandbox")).not.toBeVisible()
      expect($("#sandbox").get(0)).not.toBeVisible()


  describe "toBeHidden", ->
    it "should pass on hidden element", ->
      setFixtures sandbox().hide()
      expect($("#sandbox")).toBeHidden()
      expect($("#sandbox").get(0)).toBeHidden()

    it "should pass negated on visible element", ->
      setFixtures sandbox()
      expect($("#sandbox")).not.toBeHidden()
      expect($("#sandbox").get(0)).not.toBeHidden()


  describe "toBeSelected", ->
    beforeEach ->
      setFixtures "        <select>\n          <option id=\"not-selected\"></option>\n          <option id=\"selected\" selected=\"selected\"></option>\n        </select>"

    it "should pass on selected element", ->
      expect($("#selected")).toBeSelected()
      expect($("#selected").get(0)).toBeSelected()

    it "should pass negated on not selected element", ->
      expect($("#not-selected")).not.toBeSelected()
      expect($("#not-selected").get(0)).not.toBeSelected()


  describe "toBeChecked", ->
    beforeEach ->
      setFixtures "        <input type=\"checkbox\" id=\"checked\" checked=\"checked\" />\n        <input type=\"checkbox\" id=\"not-checked\" />"

    it "should pass on checked element", ->
      expect($("#checked")).toBeChecked()
      expect($("#checked").get(0)).toBeChecked()

    it "should pass negated on not checked element", ->
      expect($("#not-checked")).not.toBeChecked()
      expect($("#not-checked").get(0)).not.toBeChecked()


  describe "toBeEmpty", ->
    it "should pass on empty element", ->
      setFixtures sandbox()
      expect($("#sandbox")).toBeEmpty()
      expect($("#sandbox").get(0)).toBeEmpty()

    it "should pass negated on element with a tag inside", ->
      setFixtures sandbox().html($("<span />"))
      expect($("#sandbox")).not.toBeEmpty()
      expect($("#sandbox").get(0)).not.toBeEmpty()

    it "should pass negated on element with text inside", ->
      setFixtures sandbox().text("some text")
      expect($("#sandbox")).not.toBeEmpty()
      expect($("#sandbox").get(0)).not.toBeEmpty()


  describe "toExist", ->
    it "should pass on visible element", ->
      setFixtures sandbox()
      expect($("#sandbox")).toExist()
      expect($("#sandbox").get(0)).toExist()

    it "should pass on hidden element", ->
      setFixtures sandbox().hide()
      expect($("#sandbox")).toExist()
      expect($("#sandbox").get(0)).toExist()

    it "should pass negated if element is not present in DOM", ->
      expect($("#non-existent-element")).not.toExist()
      expect($("#non-existent-element").get(0)).not.toExist()

    it "should pass on negated removed element", ->
      setFixtures sandbox()
      el = $("#sandbox")
      el.remove()
      expect(el).not.toExist()


  describe "toHaveLength", ->
    it "should pass on an object with more than zero items", ->
      $three = $("<div>").add("<span>").add("<pre>")
      expect($three.length).toBe 3
      expect($three).toHaveLength 3

    it "should pass negated on an object with more than zero items", ->
      $three = $("<div>").add("<span>").add("<pre>")
      expect($three.length).toBe 3
      expect($three).not.toHaveLength 2

    it "should pass on an object with zero items", ->
      $zero = $()
      expect($zero.length).toBe 0
      expect($zero).toHaveLength 0

    it "should pass negated on an object with zero items", ->
      $zero = $()
      expect($zero.length).not.toBe 1
      expect($zero).not.toHaveLength 1


  describe "toBe", ->
    beforeEach ->
      setFixtures sandbox()

    it "should pass if object matches selector", ->
      expect($("#sandbox")).toBe "#sandbox"
      expect($("#sandbox").get(0)).toBe "#sandbox"

    it "should pass negated if object does not match selector", ->
      expect($("#sandbox")).not.toBe "#wrong-id"
      expect($("#sandbox").get(0)).not.toBe "#wrong-id"


  describe "toContain", ->
    beforeEach ->
      setFixtures sandbox().html("<span />")

    it "should pass if object contains selector", ->
      expect($("#sandbox")).toContain "span"
      expect($("#sandbox").get(0)).toContain "span"

    it "should pass negated if object does not contain selector", ->
      expect($("#sandbox")).not.toContain "div"
      expect($("#sandbox").get(0)).not.toContain "div"


  describe "toBeDisabled", ->
    beforeEach ->
      setFixtures "        <input type=\"text\" disabled=\"disabled\" id=\"disabled\"/>\n        <input type=\"text\" id=\"enabled\"/>"

    it "should pass on disabled element", ->
      expect($("#disabled")).toBeDisabled()
      expect($("#disabled").get(0)).toBeDisabled()

    it "should pass negated on not selected element", ->
      expect($("#enabled")).not.toBeDisabled()
      expect($("#enabled").get(0)).not.toBeDisabled()


  describe "toBeFocused", ->
    beforeEach ->
      setFixtures "<input type=\"text\" id=\"focused\"/>"

    it "should pass on focused element", ->
      el = $("#focused").focus()
      expect(el).toBeFocused()

    it "should pass negated on not focused element", ->
      el = $("#focused")
      expect(el).not.toBeFocused()


  describe "toHaveBeenTriggeredOn", ->
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      spyOnEvent $("#clickme"), "click"
      spyOnEvent document, "click"
      spyOnEvent $("#otherlink"), "click"

    it "should pass if the event was triggered on the object", ->
      $("#clickme").click()
      expect("click").toHaveBeenTriggeredOn $("#clickme")
      expect("click").toHaveBeenTriggeredOn "#clickme"

    it "should pass if the event was triggered on document", ->
      $(document).click()
      expect("click").toHaveBeenTriggeredOn $(document)
      expect("click").toHaveBeenTriggeredOn document

    it "should pass if the event was triggered on a descendant of document", ->
      $("#clickme").click()
      expect("click").toHaveBeenTriggeredOn $(document)
      expect("click").toHaveBeenTriggeredOn document

    it "should pass negated if the event was never triggered", ->
      expect("click").not.toHaveBeenTriggeredOn $("#clickme")
      expect("click").not.toHaveBeenTriggeredOn "#clickme"

    it "should pass negated if the event was triggered on another non-descendant object", ->
      $("#otherlink").click()
      expect("click").not.toHaveBeenTriggeredOn $("#clickme")
      expect("click").not.toHaveBeenTriggeredOn "#clickme"


  describe "toHaveBeenTriggeredOnAndWith", ->
    beforeEach ->
      spyOnEvent document, "event"

    describe "when extra parameter is an object", ->
      it "should pass if the event was triggered on the object with expected arguments", ->
        $(document).trigger "event",
          key1: "value1"
          key2: "value2"

        expect("event").toHaveBeenTriggeredOnAndWith document,
          key1: "value1"
          key2: "value2"


      it "should pass negated if the event was never triggered", ->
        expect("event").not.toHaveBeenTriggeredOnAndWith document,
          key1: "value1"
          key2: "value2"


      it "should pass negated if the event was triggered on another non-descendant object", ->
        $(window).trigger "event",
          key1: "value1"
          key2: "value2"

        expect("event").not.toHaveBeenTriggeredOnAndWith document,
          key1: "value1"
          key2: "value2"


      it "should pass negated if the event was triggered but the arguments do not match with the expected arguments", ->
        $(document).trigger "event",
          key1: "value1"

        expect("event").not.toHaveBeenTriggeredOnAndWith document,
          key1: "value1"
          key2: "value2"

        $(document).trigger "event",
          key1: "value1"
          key2: "value2"

        expect("event").not.toHaveBeenTriggeredOnAndWith document,
          key1: "value1"

        $(document).trigger "event",
          key1: "different value"

        expect("event").not.toHaveBeenTriggeredOnAndWith document,
          key1: "value1"

        $(document).trigger "event",
          different_key: "value1"

        expect("event").not.toHaveBeenTriggeredOnAndWith document,
          key1: "value1"



    describe "when extra parameter is an array", ->
      it "should pass if the event was triggered on the object with expected arguments", ->
        $(document).trigger "event", [1, 2]
        expect("event").toHaveBeenTriggeredOnAndWith document, [1, 2]

      it "should pass negated if the event was never triggered", ->
        expect("event").not.toHaveBeenTriggeredOnAndWith document, [1, 2]

      it "should pass negated if the event was triggered on another non-descendant object", ->
        $(window).trigger "event", [1, 2]
        expect("event").not.toHaveBeenTriggeredOnAndWith document, [1, 2]

      it "should pass negated if the event was triggered but the arguments do not match with the expected arguments", ->
        $(document).trigger "event", [1]
        expect("event").not.toHaveBeenTriggeredOnAndWith document, [1, 2]
        $(document).trigger "event", [1, 2]
        expect("event").not.toHaveBeenTriggeredOnAndWith document, [1]
        $(document).trigger "event", [1, 3]
        expect("event").not.toHaveBeenTriggeredOnAndWith document, [1, 2]



  describe "toHaveBeenTriggered", ->
    spyEvents = {}
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      spyEvents["#clickme"] = spyOnEvent($("#clickme"), "click")
      spyEvents["#otherlink"] = spyOnEvent($("#otherlink"), "click")

    it "should pass if the event was triggered on the object", ->
      $("#clickme").click()
      expect(spyEvents["#clickme"]).toHaveBeenTriggered()

    it "should pass negated if the event was never triggered", ->
      expect(spyEvents["#clickme"]).not.toHaveBeenTriggered()

    it "should pass negated if the event was triggered on another non-descendant object", ->
      $("#otherlink").click()
      expect(spyEvents["#clickme"]).not.toHaveBeenTriggered()

    it "should pass negated if the spy event was reset", ->
      $("#clickme").click()
      expect("click").toHaveBeenTriggeredOn $("#clickme")
      expect("click").toHaveBeenTriggeredOn "#clickme"
      expect(spyEvents["#clickme"]).toHaveBeenTriggered()
      spyEvents["#clickme"].reset()
      expect("click").not.toHaveBeenTriggeredOn $("#clickme")
      expect("click").not.toHaveBeenTriggeredOn "#clickme"
      expect(spyEvents["#clickme"]).not.toHaveBeenTriggered()


  describe "toHaveBeenPreventedOn", ->
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      spyOnEvent $("#clickme"), "click"
      spyOnEvent $("#otherlink"), "click"

    it "should pass if the event was prevented on the object", ->
      $("#clickme").bind "click", (event) ->
        event.preventDefault()

      $("#clickme").click()
      expect("click").toHaveBeenPreventedOn $("#clickme")
      expect("click").toHaveBeenPreventedOn "#clickme"

    it "should pass negated if the event was never prevented", ->
      $("#clickme").click()
      expect("click").not.toHaveBeenPreventedOn $("#clickme")
      expect("click").not.toHaveBeenPreventedOn "#clickme"

    it "should pass negated if the event was prevented on another non-descendant object", ->
      $("#otherlink").bind "click", (event) ->
        event.preventDefault()

      $("#clickme").click()
      expect("click").not.toHaveBeenPreventedOn $("#clickme")


  describe "toHaveBeenPrevented", ->
    spyEvents = {}
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      spyEvents["#clickme"] = spyOnEvent($("#clickme"), "click")
      spyEvents["#otherlink"] = spyOnEvent($("#otherlink"), "click")

    it "should pass if the event was prevented on the object", ->
      $("#clickme").bind "click", (event) ->
        event.preventDefault()

      $("#clickme").click()
      expect(spyEvents["#clickme"]).toHaveBeenPrevented()

    it "should pass negated if the event was never prevented", ->
      $("#clickme").click()
      expect(spyEvents["#clickme"]).not.toHaveBeenPrevented()

    it "should pass negated if the event was prevented on another non-descendant object", ->
      $("#otherlink").bind "click", (event) ->
        event.preventDefault()

      $("#clickme").click()
      expect(spyEvents["#clickme"]).not.toHaveBeenPrevented()

    it "should pass negated if nothing was triggered", ->
      expect(spyEvents["#clickme"]).not.toHaveBeenPrevented()


  describe "toHaveBeenStoppedOn", ->
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      spyOnEvent $("#clickme"), "click"
      spyOnEvent $("#otherlink"), "click"

    it "should pass if the event was stopped on the object", ->
      $("#clickme").bind "click", (event) ->
        event.stopPropagation()

      $("#clickme").click()
      expect("click").toHaveBeenStoppedOn $("#clickme")
      expect("click").toHaveBeenStoppedOn "#clickme"

    it "should pass negated if the event was never stopped", ->
      $("#clickme").click()
      expect("click").not.toHaveBeenStoppedOn $("#clickme")
      expect("click").not.toHaveBeenStoppedOn "#clickme"

    it "should pass negated if the event was stopped on another non-descendant object", ->
      $("#otherlink").bind "click", (event) ->
        event.stopPropagation()

      $("#clickme").click()
      expect("click").not.toHaveBeenStoppedOn $("#clickme")


  describe "toHaveBeenStopped", ->
    spyEvents = {}
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      spyEvents["#clickme"] = spyOnEvent($("#clickme"), "click")
      spyEvents["#otherlink"] = spyOnEvent($("#otherlink"), "click")

    it "should pass if the event was stopped on the object", ->
      $("#clickme").bind "click", (event) ->
        event.stopPropagation()

      $("#clickme").click()
      expect(spyEvents["#clickme"]).toHaveBeenStopped()

    it "should pass negated if the event was never stopped", ->
      $("#clickme").click()
      expect(spyEvents["#clickme"]).not.toHaveBeenStopped()

    it "should pass negated if the event was stopped on another non-descendant object", ->
      $("#otherlink").bind "click", (event) ->
        event.stopPropagation()

      $("#clickme").click()
      expect(spyEvents["#clickme"]).not.toHaveBeenStopped()

    it "should pass negated if nothing was triggered", ->
      expect(spyEvents["#clickme"]).not.toHaveBeenStopped()


  describe "toHandle", ->
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")
      handler = -> # noop

    it "should handle events on the window object", ->
      $(window).bind "resize", handler
      expect($(window)).toHandle "resize"

    it "should pass if the event is bound", ->
      $("#clickme").bind "click", handler
      expect($("#clickme")).toHandle "click"
      expect($("#clickme").get(0)).toHandle "click"

    it "should pass if the event is not bound", ->
      expect($("#clickme")).not.toHandle "click"
      expect($("#clickme").get(0)).not.toHandle "click"

    it "should pass if the namespaced event is bound", ->
      $("#clickme").bind "click", handler #another event for the click array
      $("#clickme").bind "click.NameSpace", handler
      expect($("#clickme")).toHandle "click.NameSpace"

    it "should not fail when events is empty", ->
      $("#clickme").change ->

      expect($("#clickme")).not.toHandle "click"

    it "should recognize an event with multiple namespaces", ->
      $("#clickme").bind "click.NSone.NStwo.NSthree", handler
      expect($("#clickme")).toHandle "click.NSone"
      expect($("#clickme")).toHandle "click.NStwo"
      expect($("#clickme")).toHandle "click.NSthree"
      expect($("#clickme")).toHandle "click.NSthree.NStwo"
      expect($("#clickme")).toHandle "click.NStwo.NSone"
      expect($("#clickme")).toHandle "click"

    it "should pass if a namespaced event is not bound", ->
      $("#clickme").bind "click", handler #non namespaced event
      $("#clickme").bind "click.OtherNameSpace", handler #different namespaced event
      expect($("#clickme")).not.toHandle "click.NameSpace"

    it "should handle event on any object", ->
      object = new -> # noop

      $(object).bind "click", ->

      expect($(object)).toHandle "click"


  describe "toHandleWith", ->
    beforeEach ->
      setFixtures sandbox().html("<a id=\"clickme\">Click Me</a> <a id=\"otherlink\">Other Link</a>")

    it "should pass if the event is bound with the given handler", ->
      handler = -> # noop

      $("#clickme").bind "click", handler
      expect($("#clickme")).toHandleWith "click", handler
      expect($("#clickme").get(0)).toHandleWith "click", handler

    it "should pass if the event is not bound with the given handler", ->
      handler = ->

      $("#clickme").bind "click", handler
      aDifferentHandler = ->

      expect($("#clickme")).not.toHandleWith "click", aDifferentHandler
      expect($("#clickme").get(0)).not.toHandleWith "click", aDifferentHandler

    it "should pass if the event is not bound at all", ->
      expect($("#clickme")).not.toHandle "click"
      expect($("#clickme").get(0)).not.toHandle "click"

    it "should pass if the event on window is bound with the given handler", ->
      handler = ->

      $(window).bind "resize", handler
      expect($(window)).toHandleWith "resize", handler

    it "should pass if the event on any object is bound with the given handler", ->
      object = new -> # noop

      handler = ->

      $(object).bind "click", handler
      expect($(object)).toHandleWith "click", handler



describe "jasmine.StyleFixtures", ->
  ajaxData = "some ajax data"
  fixtureUrl = "some_url"
  anotherFixtureUrl = "another_url"
  fixturesContainer = ->
    $("head style").last()

  beforeEach ->
    jasmine.getStyleFixtures().clearCache()
    spyOn(jasmine.StyleFixtures::, "loadFixtureIntoCache_").andCallFake (relativeUrl) ->
      @fixturesCache_[relativeUrl] = ajaxData


  describe "default initial config values", ->
    it "should set 'spec/javascripts/fixtures' as the default style fixtures path", ->
      expect(jasmine.getStyleFixtures().fixturesPath).toEqual "spec/javascripts/fixtures"


  describe "load", ->
    it "should insert CSS fixture within style tag into HEAD", ->
      stylesNumOld = $("head style").length
      jasmine.getStyleFixtures().load fixtureUrl
      expect($("head style").length - stylesNumOld).toEqual 1
      expect(fixturesContainer().html()).toEqual ajaxData

    it "should insert duplicated CSS fixture into one style tag when the same url is provided twice in a single call", ->
      jasmine.getStyleFixtures().load fixtureUrl, fixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should insert merged CSS of two fixtures into one style tag when two different urls are provided in a single call", ->
      jasmine.getStyleFixtures().load fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should have shortcut global method loadStyleFixtures", ->
      loadStyleFixtures fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData


  describe "appendLoad", ->
    beforeEach ->
      ajaxData = "some ajax data"

    it "should insert CSS fixture within style tag into HEAD", ->
      stylesNumOld = $("head style").length
      jasmine.getStyleFixtures().appendLoad fixtureUrl
      expect($("head style").length - stylesNumOld).toEqual 1
      expect(fixturesContainer().html()).toEqual ajaxData

    it "should insert duplicated CSS fixture into one style tag when the same url is provided twice in a single call", ->
      jasmine.getStyleFixtures().appendLoad fixtureUrl, fixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should insert merged CSS of two fixtures into one style tag when two different urls are provided in a single call", ->
      jasmine.getStyleFixtures().appendLoad fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    it "should have shortcut global method appendLoadStyleFixtures", ->
      appendLoadStyleFixtures fixtureUrl, anotherFixtureUrl
      expect(fixturesContainer().html()).toEqual ajaxData + ajaxData

    describe "with a prexisting fixture", ->
      beforeEach ->
        jasmine.getStyleFixtures().appendLoad fixtureUrl

      it "should add new content within new style tag in HEAD", ->
        jasmine.getStyleFixtures().appendLoad anotherFixtureUrl
        expect(fixturesContainer().html()).toEqual ajaxData

      it "should not delete prexisting fixtures", ->
        jasmine.getStyleFixtures().appendLoad anotherFixtureUrl
        expect(fixturesContainer().prev().html()).toEqual ajaxData



  describe "preload", ->
    describe "load after preload", ->
      it "should go from cache", ->
        jasmine.getStyleFixtures().preload fixtureUrl, anotherFixtureUrl
        jasmine.getStyleFixtures().load fixtureUrl, anotherFixtureUrl
        expect(jasmine.StyleFixtures::loadFixtureIntoCache_.callCount).toEqual 2

      it "should return correct CSSs", ->
        jasmine.getStyleFixtures().preload fixtureUrl, anotherFixtureUrl
        jasmine.getStyleFixtures().load fixtureUrl, anotherFixtureUrl
        expect(fixturesContainer().html()).toEqual ajaxData + ajaxData


    it "should not preload the same fixture twice", ->
      jasmine.getStyleFixtures().preload fixtureUrl, fixtureUrl
      expect(jasmine.StyleFixtures::loadFixtureIntoCache_.callCount).toEqual 1

    it "should have shortcut global method preloadStyleFixtures", ->
      preloadStyleFixtures fixtureUrl, anotherFixtureUrl
      expect(jasmine.StyleFixtures::loadFixtureIntoCache_.callCount).toEqual 2


  describe "set", ->
    css = "body { color: red }"
    it "should insert CSS within style tag into HEAD", ->
      stylesNumOld = $("head style").length
      jasmine.getStyleFixtures().set css
      expect($("head style").length - stylesNumOld).toEqual 1
      expect(fixturesContainer().html()).toEqual css

    it "should have shortcut global method setStyleFixtures", ->
      setStyleFixtures css
      expect(fixturesContainer().html()).toEqual css


  describe "appendSet", ->
    css = "body { color: red }"
    it "should insert CSS within style tag into HEAD", ->
      stylesNumOld = $("head style").length
      jasmine.getStyleFixtures().appendSet css
      expect($("head style").length - stylesNumOld).toEqual 1
      expect(fixturesContainer().html()).toEqual css

    it "should have shortcut global method appendSetStyleFixtures", ->
      appendSetStyleFixtures css
      expect(fixturesContainer().html()).toEqual css

    describe "when fixture container exists", ->
      beforeEach ->
        jasmine.getStyleFixtures().appendSet css

      it "should add new content within new style tag in HEAD", ->
        jasmine.getStyleFixtures().appendSet css
        expect(fixturesContainer().html()).toEqual css

      it "should not delete prexisting fixtures", ->
        jasmine.getStyleFixtures().appendSet css
        expect(fixturesContainer().prev().html()).toEqual css



  describe "cleanUp", ->
    it "should remove CSS fixtures from DOM", ->
      stylesNumOld = $("head style").length
      jasmine.getStyleFixtures().load fixtureUrl, anotherFixtureUrl
      jasmine.getStyleFixtures().cleanUp()
      expect($("head style").length).toEqual stylesNumOld


  describe "automatic DOM clean-up between tests", ->
    stylesNumOld = $("head style").length

    # WARNING: this test must be invoked first (before 'SECOND TEST')!
    it "FIRST TEST: should pollute the DOM", ->
      jasmine.getStyleFixtures().load fixtureUrl
      expect($("head style").length).toEqual stylesNumOld + 1


    # WARNING: this test must be invoked second (after 'FIRST TEST')!
    it "SECOND TEST: should see the DOM in a blank state", ->
      expect($("head style").length).toEqual stylesNumOld



describe "jasmine.StyleFixtures using real AJAX call", ->
  beforeEach ->
    defaultFixturesPath = jasmine.getStyleFixtures().fixturesPath
    jasmine.getStyleFixtures().fixturesPath = "spec/fixtures"

  afterEach ->
    jasmine.getStyleFixtures().fixturesPath = defaultFixturesPath

  describe "when fixture file exists", ->
    fixtureUrl = "real_non_mocked_fixture_style.css"
    it "should load content of fixture file", ->
      jasmine.getStyleFixtures().load fixtureUrl
      expect($("head style").last().html()).toEqual "body { background: red; }"



describe "jasmine.JSONFixtures", ->
  ajaxData =
    a: 1
    b: 2
    arr: [1, 2, "stuff"]
    hsh:
      blurp: 8
      blop: "blip"

  moreAjaxData = [1, 2, "stuff"]
  fixtureUrl = "some_json"
  anotherFixtureUrl = "another_json"
  _sortedKeys = (obj) ->
    arr = []
    for k of obj
      arr.push k
    arr.sort()

  beforeEach ->
    jasmine.getJSONFixtures().clearCache()
    spyOn(jasmine.JSONFixtures::, "loadFixtureIntoCache_").andCallFake (relativeUrl) ->
      fakeData = {}

      # we put the data directly here, instead of using the variables to simulate rereading the file
      fakeData[fixtureUrl] =
        a: 1
        b: 2
        arr: [1, 2, "stuff"]
        hsh:
          blurp: 8
          blop: "blip"

      fakeData[anotherFixtureUrl] = [1, 2, "stuff"]
      @fixturesCache_[relativeUrl] = fakeData[relativeUrl]


  describe "default initial config values", ->
    it "should set 'spec/javascripts/fixtures/json' as the default style fixtures path", ->
      expect(jasmine.getJSONFixtures().fixturesPath).toEqual "spec/javascripts/fixtures/json"


  describe "load", ->
    it "should load the JSON data under the key 'fixture_url'", ->
      data = jasmine.getJSONFixtures().load(fixtureUrl)
      expect(_sortedKeys(data)).toEqual [fixtureUrl]
      expect(data[fixtureUrl]).toEqual ajaxData

    it "should load the JSON data under the key 'fixture_url', even if it's loaded twice in one call", ->
      data = jasmine.getJSONFixtures().load(fixtureUrl, fixtureUrl)
      expect(_sortedKeys(data)).toEqual [fixtureUrl]

    it "should load the JSON data under 2 keys given two files in a single call", ->
      data = jasmine.getJSONFixtures().load(anotherFixtureUrl, fixtureUrl)
      expect(_sortedKeys(data)).toEqual [anotherFixtureUrl, fixtureUrl]
      expect(data[anotherFixtureUrl]).toEqual moreAjaxData
      expect(data[fixtureUrl]).toEqual ajaxData

    it "should have shortcut global method loadJSONFixtures", ->
      data = loadJSONFixtures(fixtureUrl, anotherFixtureUrl)
      expect(_sortedKeys(data)).toEqual [anotherFixtureUrl, fixtureUrl]
      expect(data[anotherFixtureUrl]).toEqual moreAjaxData
      expect(data[fixtureUrl]).toEqual ajaxData


  describe "getJSONFixture", ->
    it "fetches the fixture you ask for", ->
      expect(getJSONFixture(fixtureUrl)).toEqual ajaxData
      expect(getJSONFixture(anotherFixtureUrl)).toEqual moreAjaxData


  describe "reloading data will restore the fixture data", ->
    beforeEach ->
      data = jasmine.getJSONFixtures().load(anotherFixtureUrl)[anotherFixtureUrl]


    # WARNING: this test must be invoked first (before 'SECOND TEST')!
    it "FIRST TEST: should pollute the fixture data", ->
      data.push "moredata"
      expect(data.length).toEqual 4


    # WARNING: this test must be invoked second (after 'FIRST TEST')!
    it "SECOND TEST: should see cleansed JSON fixture data", ->
      expect(data.length).toEqual 3



describe "jasmine.JSONFixtures using real AJAX call", ->
  beforeEach ->
    defaultFixturesPath = jasmine.getJSONFixtures().fixturesPath
    jasmine.getJSONFixtures().fixturesPath = "spec/fixtures/json"

  afterEach ->
    jasmine.getJSONFixtures().fixturesPath = defaultFixturesPath

  describe "when fixture file exists", ->
    fixtureUrl = "jasmine_json_test.json"
    it "should load content of fixture file", ->
      data = jasmine.getJSONFixtures().load(fixtureUrl)
      expect(data[fixtureUrl]).toEqual [1, 2, 3]


