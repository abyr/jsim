describe "document", ->
  it "select body", ->
    res = $ "body"
    expect(typeof res).toEqual 'object'
  it "select head", ->
    res = $ "head"
    expect(typeof res).toEqual 'object'
  it "select html", ->
    res = $ "html"
    expect(typeof res).toEqual 'object'
  it "select element by id", ->
    res = $ "#target"
    expect(typeof res).toEqual 'object'