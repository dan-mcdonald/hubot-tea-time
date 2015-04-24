# Description
#   Reminds the team when it's tea time
#
# Commands:
#   hubot remind for tea - Asks hubot to remind you when it's time for tea

schedule = require('node-schedule')

module.exports = (bot) ->
  bot.logger.info "TEATIME: loading tea time module..."
  TEATIME_START_HOUR = 14
  TEATIME_START_MINUTE = 22
  TEATIME_END_HOUR = 16
  TEATIME_END_MINUTE = 0

  # TEATIME_START_HOUR = 11
  # TEATIME_START_MINUTE = 5
  # TEATIME_END_HOUR = 11
  # TEATIME_END_MINUTE = 7

  TEATIME_SPAN_MINUTES = (TEATIME_END_HOUR-TEATIME_START_HOUR)*60 + (TEATIME_END_MINUTE-TEATIME_START_MINUTE)

  inThePast = (date) -> date.getTime() < new Date().getTime()

  generateTeaTime = (forDate) ->
    date = new Date(forDate)
    addedMinutes = Math.floor(Math.random() * TEATIME_SPAN_MINUTES)
    rawMinutes = TEATIME_START_MINUTE + addedMinutes
    date.setHours(TEATIME_START_HOUR + Math.floor(rawMinutes / 60))
    date.setMinutes(rawMinutes % 60, 0, 0)
    date

  addDay = (date) -> new Date(date.getTime() + 24*60*60*1000)

  isTeaDay = (date) -> 1 <= date.getDay() <= 5

  nextTeaDay = (oldDate) ->
    newDate = addDay(oldDate)
    while !isTeaDay(newDate)
      newDate = addDay(newDate)
    newDate

  job = null
  scheduleNewTeaTime = (forDate, res) ->
    teaTime = generateTeaTime(forDate)
    if inThePast(teaTime)
      scheduleNewTeaTime(nextTeaDay(forDate), res)
    else
      bot.logger.info "TEATIME: Next tea time will be #{teaTime}"
      job = schedule.scheduleJob(teaTime, () ->
        bot.logger.info "TEATIME: Cron scheduler fired at #{new Date()}"
        res.send "@here I do believe it is time for tea. Who would like to go?"
        job.cancel()
        scheduleNewTeaTime(nextTeaDay(teaTime), res)
      )

  bot.respond /remind for tea time/i, (res) ->
    firstTeaDay = new Date()
    if !isTeaDay(firstTeaDay)
      firstTeaDay = nextTeaDay(firstTeaDay)
    scheduleNewTeaTime(firstTeaDay, res)

  bot.logger.info "TEATIME: tea time module loaded"
