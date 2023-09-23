const cds = require("@sap/cds");

/*module.exports = cds.service.impl(async function () {
    const { Incidents } = this.entities;
    const sapbackend = await cds.connect.to("sapbackend");
    this.on("READ", Incidents, async req => {
        return await sapbackend.tx(req).send({
            query: req.query,
            headers: {
                Authorization: "Basic c2FwdWk10nNhcHVpNQ=="
            }
        })
    })
});*/

module.exports = async srv => {
    const sapbackend = await cds.connect.to("sapbackend");
    const { Incidents } = srv.entities;

    srv.on(["READ"], Incidents, async req => {
        let incidentQuery = SELECT.from(req.query.SELECT.from).limit(
            req.query.SELECT.limit
        );

        if (req.query.SELECT.where) {
            incidentQuery.where(req.query.SELECT.where);
        }

        if (req.query.SELECT.orderBy) {
            incidentQuery.orderBy(req.query.SELECT.orderBy);
        }

        let incident = await sapbackend.tx(req).send({
            query: incidentQuery,
            header: {
                Authorization: `${process.env.SAP_GATEWAY_AUTH}`
            },
        })

        let incidents = [];
        if (Array.isArray(incident)) {
            incidents = incident
        } else {
            incidents[0] = incident
        }

        return incidents
    })
}