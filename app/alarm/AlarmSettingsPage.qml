/*
 * Copyright (C) 2014-2015 Canonical Ltd
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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import WorldClock 1.0
import Alarm 1.0
import Ubuntu.Components 1.2
import "../components"

Page {
    id: _alarmSettings

    title: i18n.tr("Settings")
    visible: false
    flickable: settingsPlugin

    Connections {
        target: clockApp
        onApplicationStateChanged: {
            localTimeSource.update()
        }
    }

    DateTime {
        id: localTimeSource
    }

    AlarmSettings {
        id: alarmSettings
    }

    ListModel {
        id: durationModel
        Component.onCompleted: initialise()

        function initialise() {
            // TRANSLATORS: Alarm stops after
            durationModel.append({ "duration": 10, "text": i18n.tr("%1 minute", "%1 minutes", 10).arg(10) })
            durationModel.append({ "duration": 20, "text": i18n.tr("%1 minute", "%1 minutes", 20).arg(20) })
            durationModel.append({ "duration": 30, "text": i18n.tr("%1 minute", "%1 minutes", 30).arg(30) })
            durationModel.append({ "duration": 60, "text": i18n.tr("%1 minute", "%1 minutes", 60).arg(60) })
        }
    }

    ListModel {
        id: snoozeModel
        Component.onCompleted: initialise()

        function initialise() {
            // TRANSLATORS: Snooze for
            snoozeModel.append({ "duration": 2, "text": i18n.tr("%1 minute", "%1 minutes", 2).arg(2) })
            snoozeModel.append({ "duration": 5, "text": i18n.tr("%1 minute", "%1 minutes", 5).arg(5) })
            snoozeModel.append({ "duration": 10, "text": i18n.tr("%1 minute", "%1 minutes", 10).arg(10) })
            snoozeModel.append({ "duration": 15, "text": i18n.tr("%1 minute", "%1 minutes", 15).arg(15) })
        }
    }

    Flickable {
        id: settingsPlugin

        contentHeight: _settingsColumn.height
        anchors.fill: parent

        Column {
            id: _settingsColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ListItem {
                height: 2 * implicitHeight

                Label {
                    color: UbuntuColors.midAubergine
                    text: i18n.tr("Alarm volume")
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        top: parent.top
                        topMargin: units.gu(1)
                    }
                }

                Slider {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    minimumValue: 1
                    maximumValue: 100
                    value: alarmSettings.volume

                    onValueChanged: {
                        alarmSettings.volume = formatValue(value)
                    }
                }
            }

            ExpandableListItem {
                id: _alarmDuration

                listViewHeight: units.gu(28)
                text: i18n.tr("Alarm stops after")
                subText: i18n.tr("%1 minute", "%1 minutes", alarmSettings.duration).arg(alarmSettings.duration)

                model: durationModel

                delegate: ListItem {
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.text
                            Layout.fillWidth: true
                        }

                        Icon {
                            width: units.gu(2)
                            height: width
                            name: "ok"
                            visible: alarmSettings.duration === duration
                        }
                    }

                    onClicked: {
                        alarmSettings.duration = duration
                        _alarmDuration.expanded = false
                    }
                }
            }

            ExpandableListItem {
                id: _alarmSnooze

                listViewHeight: units.gu(28)
                text: i18n.tr("Snooze for")
                subText: i18n.tr("%1 minute", "%1 minutes", alarmSettings.snoozeDuration).arg(alarmSettings.snoozeDuration)

                model: snoozeModel

                delegate: ListItem {
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.text
                            Layout.fillWidth: true
                        }

                        Icon {
                            width: units.gu(2)
                            height: width
                            name: "ok"
                            visible: alarmSettings.snoozeDuration === duration
                        }
                    }

                    onClicked: {
                        alarmSettings.snoozeDuration = duration
                        _alarmSnooze.expanded = false
                    }
                }
            }

            ListItem {
                Label {
                    text: i18n.tr("Vibration")
                    color: UbuntuColors.midAubergine
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                }

                Switch {
                    id: vibrateSwitch

                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    checked: alarmSettings.vibration === "pulse"
                    onCheckedChanged: {
                        if(checked) {
                            alarmSettings.vibration = "pulse"
                        } else {
                            alarmSettings.vibration = "none"
                        }
                    }
                }

                onClicked: {
                    vibrateSwitch.checked = !vibrateSwitch.checked
                }
            }

            SubtitledListItem {
                text: i18n.tr("Change time and date")
                subText: {
                    /*
                  FIXME: When the upstream QT bug at
                  https://bugreports.qt-project.org/browse/QTBUG-40275 is fixed
                  it will be possible to receive a datetime object directly
                  instead of using this hack.
                */
                    var localTime = new Date
                            (
                                localTimeSource.localDateString.split(":")[0],
                                localTimeSource.localDateString.split(":")[1]-1,
                                localTimeSource.localDateString.split(":")[2],
                                localTimeSource.localTimeString.split(":")[0],
                                localTimeSource.localTimeString.split(":")[1],
                                localTimeSource.localTimeString.split(":")[2],
                                localTimeSource.localTimeString.split(":")[3]
                                )
                    return localTime.toLocaleString()
                }

                onClicked: {
                    Qt.openUrlExternally("settings:///system/time-date")
                }
            }
        }
    }
}
