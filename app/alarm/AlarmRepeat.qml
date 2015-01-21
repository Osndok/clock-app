/*
 * Copyright (C) 2014 Canonical Ltd
 *
 * This file is part of Ubuntu Clock App
 *
 * Ubuntu Clock App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Clock App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
    id: _alarmRepeatPage
    objectName: "alarmRepeatPage"

    // Property to set the alarm days of the week in the edit alarm page
    property var alarm

    // Property to hold the alarm utils functions passed from edit alarm page
    property var alarmUtils

    visible: false
    title: i18n.tr("Repeat")

    head.actions: [
        Action {
            text: i18n.tr("Select All")

            iconSource: {
                if(alarm.daysOfWeek === 127)
                    return Qt.resolvedUrl("../graphics/select-none.svg")
                else
                    return Qt.resolvedUrl("../graphics/select.svg")
            }

            onTriggered: {
                if (alarm.daysOfWeek === 127) {
                    for (var i=0; i<_alarmDays.count; i++) {
                        _alarmDays.itemAt(i).isChecked = false
                    }
                }

                else {
                    for (var i=0; i<_alarmDays.count; i++) {
                        _alarmDays.itemAt(i).isChecked = true
                    }
                }
            }
        }
    ]

    /*
     By Default, the alarm is set to Today. However if it is a one-time alarm,
     this should be set to none, since this page shows the days the alarm
     repeats on and a one-time alarm shoudn't repeat on any day. While exiting
     the page, if the alarm is still a one-time alarm, then the alarm is set
     back to its original value (Today).
    */
    Component.onCompleted: {
        if (alarm.type === Alarm.OneTime)
            alarm.daysOfWeek = 0
    }

    Component.onDestruction: {
        if (alarm.type === Alarm.OneTime)
            alarm.daysOfWeek = Alarm.AutoDetect
    }

    ListModel {
        id: daysModel
        Component.onCompleted: initialise()

        // Function to generate the days of the week based on the user locale
        function initialise() {
            var i = 1

            // Get the first day of the week based on the user locale
            var j = Qt.locale().firstDayOfWeek

            // Set first item on the list to be the first day of the week
            daysModel.append({ "day": Qt.locale().standaloneDayName(j, Locale.LongFormat), "flag": alarmUtils.get_alarm_day(j) })

            // Retrieve the rest of the days of the week
            while (i<=6) {
                daysModel.append({ "day": Qt.locale().standaloneDayName((j+i)%7, Locale.LongFormat), "flag": alarmUtils.get_alarm_day((j+i)%7) })
                i++
            }
        }
    }

    Column {
        id: _alarmDayColumn

        anchors.fill: parent

        Repeater {
            id: _alarmDays
            objectName: 'alarmDays'

            model: daysModel

            ListItem.Standard {
                id: _alarmDayHolder
                objectName: "alarmDayHolder" + index

                property alias isChecked: daySwitch.checked

                Label {
                    id: _alarmDay
                    objectName: 'alarmDay' + index

                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    color: UbuntuColors.midAubergine
                    text: day
                }

                control: CheckBox {
                    id: daySwitch
                    objectName: 'daySwitch' + index

                    anchors {
                        right: parent.right
                        rightMargin: units.gu(-0.2)
                    }

                    checked: (alarm.daysOfWeek & flag) == flag
                             && alarm.type === Alarm.Repeating
                    onCheckedChanged: {
                        if (checked) {
                            alarm.daysOfWeek |= flag
                        } else {
                            alarm.daysOfWeek &= ~flag
                        }

                        if (alarm.daysOfWeek > 0) {
                            alarm.type = Alarm.Repeating
                        } else {
                            alarm.type = Alarm.OneTime
                        }
                    }
                }
            }
        }
    }
}
