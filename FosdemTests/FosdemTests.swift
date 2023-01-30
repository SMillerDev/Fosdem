//
//  FosdemTests.swift
//  FosdemTests
//
//  Created by Sean Molenaar on 02/02/2019.
//  Copyright © 2019 Sean Molenaar. All rights reserved.
//

import XCTest
import CoreData
@testable import Fosdem

class FosdemTests: XCTestCase {

    override func setUp() {
        let context = TestCoreDataStack().persistentContainer.newBackgroundContext()
        DataImporter.context = context
    }

    override func tearDown() {
    }

    func testProcessDataSucceeds2019() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "schedule_2019", withExtension: "xml")!
        let xmlData = try? Data(contentsOf: url)
        XCTAssertNotNil(xmlData, "No test data")

        expectation(
          forNotification: .NSManagedObjectContextDidSave,
          object: DataImporter.context) { _ in
            return true
        }

        DataImporter.handler = { conference in
            XCTAssertNotNil(conference, "Conference parsed")
            XCTAssertEqual(conference.name, "FOSDEM 2019")
            XCTAssertEqual(conference.venue, "ULB (Université Libre de Bruxelles)")
            XCTAssertEqual(conference.start.timeIntervalSince1970, TimeInterval("1549065600"))
            XCTAssertEqual(conference.end.timeIntervalSince1970, TimeInterval("1549152000"))
            XCTAssertNotNil(conference.events)
            XCTAssertEqual(conference.events.count, 775)
        }
        DataImporter.process(xmlData!)

        waitForExpectations(timeout: 30) { error in
          XCTAssertNil(error, "Save did not occur")
        }
    }

    func testProcessDataSucceedsVirtual() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "schedule_2022", withExtension: "xml")!
        let xmlData = try? Data(contentsOf: url)
        XCTAssertNotNil(xmlData, "No test data")

        expectation(
          forNotification: .NSManagedObjectContextDidSave,
          object: DataImporter.context) { _ in
            return true
        }

        DataImporter.handler = { conference in
            XCTAssertNotNil(conference, "Conference parsed")
            XCTAssertEqual(conference.name, "FOSDEM 2022")
            XCTAssertEqual(conference.venue, "ULB (Université Libre de Bruxelles)")
            XCTAssertEqual(conference.start.timeIntervalSince1970, TimeInterval("1644019200"))
            XCTAssertEqual(conference.end.timeIntervalSince1970, TimeInterval("1644105600"))
            XCTAssertNotNil(conference.events)
            XCTAssertEqual(conference.events.count, 730)
        }
        DataImporter.process(xmlData!)

        waitForExpectations(timeout: 30) { error in
          XCTAssertNil(error, "Save did not occur")
        }
    }

    func testProcessDataSucceedsEmpty() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "schedule_2023", withExtension: "xml")!
        let xmlData = try? Data(contentsOf: url)
        XCTAssertNotNil(xmlData, "No test data")

        expectation(
          forNotification: .NSManagedObjectContextDidSave,
          object: DataImporter.context) { _ in
            return true
        }

        DataImporter.handler = { conference in
            XCTAssertNotNil(conference, "Conference parsed")
            XCTAssertEqual(conference.name, "FOSDEM 2023")
            XCTAssertEqual(conference.venue, "ULB (Université Libre de Bruxelles)")
            XCTAssertEqual(conference.start.timeIntervalSince1970, TimeInterval("1675468800"))
            XCTAssertEqual(conference.end.timeIntervalSince1970, TimeInterval("1675555200"))
            XCTAssertNotNil(conference.events)
            XCTAssertEqual(conference.events.count, 0)
        }
        DataImporter.process(xmlData!)

        waitForExpectations(timeout: 10) { error in
          XCTAssertNil(error, "Save did not occur")
        }
    }

}

class TestCoreDataStack: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        let container = NSPersistentContainer(name: "Fosdem")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
