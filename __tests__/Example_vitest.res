open Vitest

describe("it", () => {
  open Expect

  test("works", () => {
    true->expect->toEqual(true)
  })
})
