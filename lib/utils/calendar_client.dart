import 'package:events_demo/secrets.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarClient {
  static const _scopes = const [CalendarApi.CalendarScope];

  Future<Map<String, String>> insert({
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String year,
  }) async {
    var _clientID = new ClientId(Secret.ANDROID_CLIENT_ID, "");
    Map<String, String> eventData;

    await clientViaUserConsent(_clientID, _scopes, prompt)
        .then((AuthClient client) async {
      var calendar = CalendarApi(client);

      print('Students notified: $year');

      // List<String> attendeeEmails = UserDetails.getEmailList(year);
      List<EventAttendee> attendeeEmailList = [];

      // for (String attendeeEmail in attendeeEmails) {
      //   EventAttendee eventAttendee = EventAttendee();
      //   eventAttendee.email = attendeeEmail;

      //   attendeeEmailList.add(eventAttendee);
      // }

      String calendarId = "primary";
      Event event = Event();

      ConferenceData conferenceData = ConferenceData();
      CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
      conferenceRequest.requestId =
          "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
      conferenceData.createRequest = conferenceRequest;

      event.summary = title;
      event.description = description;
      event.attendees = attendeeEmailList;
      event.conferenceData = conferenceData;
      event.location = "Online";

      EventDateTime start = new EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+05:30";
      event.start = start;

      EventDateTime end = new EventDateTime();
      end.timeZone = "GMT+05:30";
      end.dateTime = endTime;
      event.end = end;

      try {
        await calendar.events
            .insert(event, calendarId,
                conferenceDataVersion: 1, sendUpdates: "all")
            .then((value) {
          print("Event Status: ${value.status}");
          if (value.status == "confirmed") {
            print(value.conferenceData.conferenceId);
            print(value.id);

            String joiningLink;
            String eventId;

            eventId = value.id;
            joiningLink =
                "https://meet.google.com/${value.conferenceData.conferenceId}";

            eventData = {'id': eventId, 'link': joiningLink};

            print('Event added in google calendar');
          } else {
            print("Unable to add event in google calendar");
          }
        });
      } catch (e) {
        print('Error creating event $e');
      }
    });

    return eventData;
  }

  Future<Map<String, String>> modify({
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String eventId,
    String year,
  }) async {
    var _clientID = new ClientId(Secret.ANDROID_CLIENT_ID, "");
    Map<String, String> eventData;

    await clientViaUserConsent(_clientID, _scopes, prompt)
        .then((AuthClient client) async {
      var calendar = CalendarApi(client);

      print('Students notified: $year');

      // List<String> attendeeEmails = UserDetails.getEmailList(year);
      List<EventAttendee> attendeeEmailList = [];

      // for (String attendeeEmail in attendeeEmails) {
      //   EventAttendee eventAttendee = EventAttendee();
      //   eventAttendee.email = attendeeEmail;

      //   attendeeEmailList.add(eventAttendee);
      // }

      String calendarId = "primary";
      Event event = Event();

      ConferenceData conferenceData = ConferenceData();
      CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
      conferenceRequest.requestId =
          "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
      conferenceData.createRequest = conferenceRequest;

      event.summary = title;
      event.description = description;
      event.attendees = attendeeEmailList;
      event.conferenceData = conferenceData;
      event.location = "Online";

      EventDateTime start = new EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+05:30";
      event.start = start;

      EventDateTime end = new EventDateTime();
      end.timeZone = "GMT+05:30";
      end.dateTime = endTime;
      event.end = end;

      try {
        await calendar.events
            .patch(event, calendarId, eventId,
                conferenceDataVersion: 1, sendUpdates: "all")
            .then((value) {
          print("Event Status: ${value.status}");
          if (value.status == "confirmed") {
            print(value.conferenceData.conferenceId);
            print(value.id);

            String joiningLink;
            String eventId;

            eventId = value.id;
            joiningLink =
                "https://meet.google.com/${value.conferenceData.conferenceId}";

            eventData = {'id': eventId, 'link': joiningLink};

            print('Event updated in google calendar');
          } else {
            print("Unable to update event in google calendar");
          }
        });
      } catch (e) {
        print('Error updating event $e');
      }
    });

    return eventData;
  }

  Future<void> delete(String eventId) async {
    var _clientID = new ClientId(Secret.ANDROID_CLIENT_ID, "");

    await clientViaUserConsent(_clientID, _scopes, prompt)
        .then((AuthClient client) async {
      var calendar = CalendarApi(client);

      String calendarId = "primary";

      try {
        await calendar.events
            .delete(calendarId, eventId, sendUpdates: "all")
            .then((value) {
          print('Event deleted from google calendar');
        });
      } catch (e) {
        print('Error creating event $e');
      }
    });
  }

  void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
