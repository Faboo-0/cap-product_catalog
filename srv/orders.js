const cds = require("@sap/cds")
const { Orders } = cds.entities("com.training")

module.exports = (srv) => {
    srv.on("READ", "Orders", async (req) => {
        if (req.data.ClientEmail !== undefined) {
            return await SELECT.from`com.training.Orders`.where`ClientEmail = ${req.data.ClientEmail}`
        }
        return await SELECT.from(Orders);
    })

    srv.after("READ", "Orders", (data) => {
        return data.map((elem) => (elem.Reviewed = true))
    })

    srv.on("CREATE", "Orders", async (req) => {
        return await cds.transaction(req).run(
            INSERT.into(Orders).entries({
                ClientEmail: req.data.ClientEmail,
                FirstName: req.data.FirstName,
                LastName: req.data.LastName,
                CreatedOn: req.data.CreatedOn,
                Reviewed: req.data.Reviewed,
                Approved: req.data.Approved
            })
        ).then((resolve, reject) => {
            console.log("Resolve", resolve)
            console.log("Reject", reject)
            if (typeof resolve !== "undefined") {
                return req.data;
            } else {
                req.error(409, "Record not inserted")
            }
        }).catch((err) => {
            console.log(err)
            req.error(err.code, err.message)
        })
    })

    srv.before("CREATE", "Orders", (req) => {
        return req.data.CreatedOn = new Date().toISOString().slice(0,10)
    })

    srv.on("UPDATE", "Orders", async (req) => {
        let returnData = await cds.transaction(req).run([
            UPDATE(Orders, req.data.ClientEmail).set({
                FirstName: req.data.FirstName,
                LastName: req.data.LastName
            })
        ]).then((resolve, reject) => {
            console.log("Resolve: " + resolve)
            console.log("Reject: " + reject)

            if(resolve[0] == 0){
                req.error(409, "Record Not Found");
            }
        }).catch(err => {
            console.log(err)
            req.error("Error: " + err)
        })
        return returnData
    })

    srv.on("DELETE", "Orders", async req => {
        return await cds.transaction(req).run(
            DELETE.from(Orders).where({
                ClientEmail : req.data.ClientEmail
            })
        ).then((resolve, reject) => {
            console.log("Resolve " + resolve)
            console.log("Reject" + reject)
            if(resolve !== 1)
                req.error(409, "Record Not Found");
        }).catch(err => {
            console.log(err)
            req.error(err.code, err.message);
        })
    })
}

